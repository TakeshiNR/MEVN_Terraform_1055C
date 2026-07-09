# =============================================================================
# VARIABLES DEL ROOT MODULE
# Aqui se centralizan todos los parametros configurables del proyecto.
# Los valores reales se definen en terraform.tfvars (no versionar si contiene
# datos sensibles; usar terraform.tfvars.example como plantilla).
# =============================================================================

variable "aws_region" {
  description = "Region de AWS donde se despliega todo el stack"
  type        = string
  default     = "us-west-1"
}

variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo de todos los recursos"
  type        = string
  default     = "mevn-tasks"
}

# -----------------------------------------------------------------------------
# Red
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs a usar (deben pertenecer a aws_region)"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs para las subredes publicas (ALB + NAT GW)"
  type        = map(string)
  default = {
    "0" = "10.0.0.0/24"
    "1" = "10.0.1.0/24"
  }
}

variable "web_subnet_cidrs" {
  description = "CIDRs para las subredes privadas de la capa web"
  type        = map(string)
  default = {
    "0" = "10.0.10.0/24"
    "1" = "10.0.11.0/24"
  }
}

variable "backend_subnet_cidrs" {
  description = "CIDRs para las subredes privadas de la capa backend"
  type        = map(string)
  default = {
    "0" = "10.0.20.0/24"
    "1" = "10.0.21.0/24"
  }
}

variable "db_subnet_cidrs" {
  description = "CIDRs para la subred privada de la capa de datos (una sola: el modulo mongodb crea UNA instancia)"
  type        = map(string)
  default = {
    "0" = "10.0.30.0/24"
  }
}

# -----------------------------------------------------------------------------
# Seguridad
# -----------------------------------------------------------------------------
variable "admin_cidr" {
  description = "IP publica del administrador en formato CIDR (ej: 190.12.34.56/32) para permitir SSH. NO dejar 0.0.0.0/0 en produccion."
  type        = string
}

variable "key_name" {
  description = "Nombre del Key Pair de EC2 ya creado en la region (recordar: los key pairs son especificos de cada region)"
  type        = string
}

# -----------------------------------------------------------------------------
# AMIs por capa
# web_ami_id / backend_ami_id: si se dejan en null, se usa automaticamente la
# ultima AMI publica de Amazon Linux 2023 (data.aws_ami.amazon_linux_2023) y
# el user_data instala nginx/node en el arranque. Se pueden sobreescribir con
# una AMI propia (p.ej. generada con Packer) si se prefiere.
# -----------------------------------------------------------------------------
variable "web_ami_id" {
  description = "AMI para la capa web. null = usar la ultima Amazon Linux 2023 publica"
  type        = string
  default     = null
}

variable "backend_ami_id" {
  description = "AMI para la capa backend (Express). null = usar la ultima Amazon Linux 2023 publica"
  type        = string
  default     = null
}

variable "db_ami_id" {
  description = "AMI para la instancia MongoDB (ver default en modules/mongodb/variables.tf)"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para todas las capas (se puede desglosar por capa si se necesita)"
  type        = string
  default     = "t2.micro"
}

variable "backend_port" {
  description = "Puerto de la API Express"
  type        = number
  default     = 3000
}

variable "mongo_port" {
  description = "Puerto de MongoDB"
  type        = number
  default     = 27017
}

variable "mongo_db_name" {
  description = "Nombre de la base de datos Mongo que usara el backend"
  type        = string
  default     = "mevn_tasks"
}
