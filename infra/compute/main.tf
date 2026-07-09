# =============================================================================
# MODULO: compute
# -----------------------------------------------------------------------------
# Responsabilidad de este modulo:
#   Es un modulo GENERICO de instancias EC2. No sabe si es "web" o "backend";
#   simplemente recibe parametros (AMI, tipo de instancia, subredes, security
#   group, user_data, perfil IAM opcional) y crea N instancias (una por
#   subred recibida).
#
#   Se instancia 2 veces desde el root module (main.tf):
#     module "web_instances"     -> capa Vue/Nginx
#     module "backend_instances" -> capa Express
#   (La capa de datos usa el modulo ../mongodb, que ya trae su propia logica
#   de instalacion real de MongoDB, en vez de este modulo generico.)
#
# Justificacion de por que este es un modulo unico y no varios modulos:
#   web y backend comparten exactamente la misma logica de creacion de una
#   instancia EC2 (mismo recurso aws_instance, mismos argumentos). La UNICA
#   diferencia real entre capas son los VALORES de entrada (AMI, subred,
#   security group, script de arranque). Duplicar el modulo violaria el
#   principio DRY (Don't Repeat Yourself); en su lugar, parametrizamos un
#   solo modulo y lo llamamos con distintos inputs.
# =============================================================================

resource "aws_instance" "this" {
  for_each = var.subnet_ids

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = each.value
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = var.associate_public_ip
  iam_instance_profile        = var.iam_instance_profile_name
  user_data                   = var.user_data
  # AWS no vuelve a ejecutar el user_data en una instancia ya arrancada; sin
  # esto, cambiar el script (o el contenido del artefacto S3, via el hash que
  # main.tf inyecta en el template) no tendria efecto hasta un reemplazo.
  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.tier_name}-${each.key}"
    Tier = var.tier_name
  }
}
