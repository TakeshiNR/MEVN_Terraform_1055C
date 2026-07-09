variable "ami_id" {
  description = "AMI para la instancia MongoDB (Amazon Linux 2, con repo yum de MongoDB 6.0)"
  default     = "ami-0c02fb55956c7d316"
}

variable "vpc_id" {
  description = "ID de la VPC principal"
}
variable "subnet_id" {
  description = "ID de la subnet privada donde vive MongoDB"
}
variable "app_sg_id" {
  description = "ID del Security Group del app server"
}
variable "project_name" {
  description = "Nombre del proyecto para los tags"
  default     = "mean-stack"
}
variable "instance_type" {
  description = "Tipo de instancia EC2 para MongoDB"
  default     = "t2.micro"
}
variable "key_name" {
  description = "Nombre del key pair SSH para acceder a la instancia"
}