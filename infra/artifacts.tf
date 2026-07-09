# =============================================================================
# ARTEFACTOS DE APLICACION (frontend/backend) VIA S3
# -----------------------------------------------------------------------------
# El codigo de frontend/ y backend/ vive en la RAIZ del repo (hermanos de esta
# carpeta infra/), no en un repositorio aparte. En vez de hacer "git clone" de
# un repo externo desde el user_data, este modulo:
#   1) empaqueta localmente ../frontend/dist y ../backend en dos .zip,
#   2) los sube a un bucket S3 privado,
#   3) el user_data de cada instancia (ver scripts/*.sh.tpl) los descarga con
#      la AWS CLI (usan el NAT Gateway ya creado por networking, no necesitan
#      IP publica ni acceso SSH) y los despliega.
#
# Si frontend/dist o backend/ todavia no existen (equipo no ha corrido
# "npm run build" o no ha escrito el backend), el archivo/objeto se omite
# automaticamente (count = 0) y el user_data simplemente no descarga nada,
# para no romper "terraform plan/apply" mientras el resto del equipo trabaja.
# =============================================================================

locals {
  frontend_dist_path = "${path.root}/../frontend/dist"
  backend_src_path   = "${path.root}/../backend"

  frontend_built = fileexists("${local.frontend_dist_path}/index.html")
  backend_built  = fileexists("${local.backend_src_path}/package.json")
}

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Bucket de artefactos (privado, sin acceso publico)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Empaquetado local (zip) de cada app
# -----------------------------------------------------------------------------
data "archive_file" "frontend" {
  count       = local.frontend_built ? 1 : 0
  type        = "zip"
  source_dir  = local.frontend_dist_path
  output_path = "${path.root}/.artifacts/frontend.zip"
}

data "archive_file" "backend" {
  count       = local.backend_built ? 1 : 0
  type        = "zip"
  source_dir  = local.backend_src_path
  output_path = "${path.root}/.artifacts/backend.zip"
  excludes    = ["node_modules", ".env"]
}

resource "aws_s3_object" "frontend" {
  count  = local.frontend_built ? 1 : 0
  bucket = aws_s3_bucket.artifacts.id
  key    = "frontend/frontend.zip"
  source = data.archive_file.frontend[0].output_path
  etag   = data.archive_file.frontend[0].output_md5
}

resource "aws_s3_object" "backend" {
  count  = local.backend_built ? 1 : 0
  bucket = aws_s3_bucket.artifacts.id
  key    = "backend/backend.zip"
  source = data.archive_file.backend[0].output_path
  etag   = data.archive_file.backend[0].output_md5
}

# -----------------------------------------------------------------------------
# IAM: permite a las instancias web/backend leer (solo lectura) el bucket de
# artefactos, sin necesitar credenciales estaticas ni acceso SSH.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_instance" {
  name               = "${var.project_name}-app-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "s3_read_artifacts" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn]
  }
}

resource "aws_iam_role_policy" "s3_read_artifacts" {
  name   = "${var.project_name}-s3-read-artifacts"
  role   = aws_iam_role.app_instance.id
  policy = data.aws_iam_policy_document.s3_read_artifacts.json
}

resource "aws_iam_instance_profile" "app_instance" {
  name = "${var.project_name}-app-instance-profile"
  role = aws_iam_role.app_instance.name
}
