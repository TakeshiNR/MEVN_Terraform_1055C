variable "subnet_id" {
  type        = string
  description = "Subred donde se desplegará la instancia de aplicación"
}

variable "security_group_id" {
  type        = string
  description = "Security group para la instancia de aplicación"
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2 para la aplicación"
}

variable "ami_id" {
  type        = string
  description = "AMI para la instancia de aplicación"
}

variable "key_pair_name" {
  type        = string
  description = "Nombre del key pair para SSH"
}
