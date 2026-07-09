variable "project_name" {
  description = "Nombre del proyecto (prefijo de nombres)"
  type        = string
}

variable "tier_name" {
  description = "Nombre de la capa: web | backend (solo para etiquetado/nombrado)"
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI a usar (Amazon Linux, con user_data instalando lo que falte)"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2, ej: t2.micro"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre del Key Pair de EC2 para acceso SSH"
  type        = string
}

variable "subnet_ids" {
  description = "Mapa índice -> subnet_id; se crea UNA instancia por cada entrada del mapa"
  type        = map(string)
}

variable "security_group_id" {
  description = "ID del security group a asociar a las instancias de esta capa"
  type        = string
}

variable "associate_public_ip" {
  description = "Si es true, la instancia recibe IP publica (solo tiene sentido en subredes publicas o para pruebas)"
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "Nombre del instance profile IAM a asociar (p.ej. para permitir leer el bucket S3 de artefactos). null si no se necesita."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Script de arranque (cloud-init/bash) para configurar la instancia al lanzarla"
  type        = string
  default     = ""
}

variable "volume_size" {
  description = "Tamaño en GB del disco raiz"
  type        = number
  default     = 20
}
