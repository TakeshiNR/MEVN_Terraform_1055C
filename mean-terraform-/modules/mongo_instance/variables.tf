variable "subnet_id" {
  type        = string
  description = "Subred privada para MongoDB"
}

variable "security_group_id" {
  type        = string
  description = "Security group para MongoDB"
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2 para MongoDB"
}

variable "ami_id" {
  type        = string
  description = "AMI para la instancia MongoDB"
}

variable "key_pair_name" {
  type        = string
  description = "Nombre del key pair para SSH"
}
