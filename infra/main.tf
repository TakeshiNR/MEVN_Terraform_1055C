# =============================================================================
# ROOT MODULE - main.tf
# -----------------------------------------------------------------------------
# Orquesta los modulos del proyecto en el orden logico de dependencias:
#   1) networking       -> crea VPC/subredes/NAT (no depende de nadie)
#   2) security-groups   -> depende de networking (necesita el vpc_id)
#   3) mongodb            -> depende de networking + security-groups (backend_sg)
#   4) compute (web, backend) -> depende de networking + security-groups
#      (backend_instances tambien depende de mongodb, para conocer su IP)
#      (web_instances tambien depende de backend_instances, para el proxy /api/)
#   5) load-balancer      -> depende de networking + security-groups + compute
#
# El codigo de frontend/ y backend/ NO se clona desde un repo: ya viven en la
# raiz de este proyecto (hermanos de infra/). Ver artifacts.tf para el
# empaquetado/subida a S3 y scripts/*.sh.tpl para el despliegue en cada
# instancia.
# =============================================================================

# AMI publica por defecto para web/backend cuando no se especifica una propia
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# -----------------------------------------------------------------------------
# 1) Red
# -----------------------------------------------------------------------------
module "networking" {
  source = "./networking"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  web_subnet_cidrs     = var.web_subnet_cidrs
  backend_subnet_cidrs = var.backend_subnet_cidrs
  db_subnet_cidrs      = var.db_subnet_cidrs
}

# -----------------------------------------------------------------------------
# 2) Security Groups (ALB, web, backend; el SG de MongoDB lo crea ./mongodb)
# -----------------------------------------------------------------------------
module "security_groups" {
  source = "./security-groups"

  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  admin_cidr   = var.admin_cidr
  backend_port = var.backend_port
}

# -----------------------------------------------------------------------------
# 3) MongoDB - modulo dedicado ya presente en infra/, con instalacion real
# -----------------------------------------------------------------------------
module "mongodb" {
  source = "./mongodb"

  project_name  = var.project_name
  vpc_id        = module.networking.vpc_id
  subnet_id     = values(module.networking.db_subnet_ids)[0]
  app_sg_id     = module.security_groups.backend_sg_id
  ami_id        = var.db_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
}

# -----------------------------------------------------------------------------
# 4) Compute - una llamada al modulo generico "compute" POR CAPA
# -----------------------------------------------------------------------------

# --- Capa BACKEND (Express) ---------------------------------------------------
module "backend_instances" {
  source = "./compute"

  project_name              = var.project_name
  tier_name                 = "backend"
  ami_id                    = coalesce(var.backend_ami_id, data.aws_ami.amazon_linux_2023.id)
  instance_type             = var.instance_type
  key_name                  = var.key_name
  subnet_ids                = module.networking.backend_subnet_ids
  security_group_id         = module.security_groups.backend_sg_id
  associate_public_ip       = false
  iam_instance_profile_name = aws_iam_instance_profile.app_instance.name
  user_data = templatefile("${path.module}/scripts/backend-user-data.sh.tpl", {
    aws_region   = var.aws_region
    s3_bucket    = aws_s3_bucket.artifacts.id
    s3_key       = local.backend_built ? aws_s3_object.backend[0].key : ""
    backend_port = var.backend_port
    mongo_host   = module.mongodb.private_ip
    mongo_port   = var.mongo_port
    mongo_db     = var.mongo_db_name
  })
}

# --- Capa WEB (Vue + Nginx) ---------------------------------------------------
module "web_instances" {
  source = "./compute"

  project_name              = var.project_name
  tier_name                 = "web"
  ami_id                    = coalesce(var.web_ami_id, data.aws_ami.amazon_linux_2023.id)
  instance_type             = var.instance_type
  key_name                  = var.key_name
  subnet_ids                = module.networking.web_subnet_ids
  security_group_id         = module.security_groups.web_sg_id
  associate_public_ip       = false # el trafico entra siempre por el ALB
  iam_instance_profile_name = aws_iam_instance_profile.app_instance.name
  user_data = templatefile("${path.module}/scripts/web-user-data.sh.tpl", {
    aws_region   = var.aws_region
    s3_bucket    = aws_s3_bucket.artifacts.id
    s3_key       = local.frontend_built ? aws_s3_object.frontend[0].key : ""
    backend_ips  = values(module.backend_instances.private_ips)
    backend_port = var.backend_port
  })
}

# -----------------------------------------------------------------------------
# 5) Balanceador de carga - reparte trafico entre instancias web
# -----------------------------------------------------------------------------
module "load_balancer" {
  source = "./load-balancer"

  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_sg_id
  web_instance_ids      = module.web_instances.instance_ids
}
