variable "vpc_id" {
  description = "ID de la VPC principal"
}
variable "public_subnet_id" {
  description = "ID de la subnet pública donde vive el app server"
}
variable "mongodb_private_ip" {
  description = "IP privada de la instancia app server"
}
variable "instance_type" {
  description = "Tipo de instancia EC2 para app server"
  default     = "t2.micro"
}
variable "key_name" {
  description = "Nombre del key pair SSH para acceder a la instancia"
}
variable "project_name" {
  description = "Nombre del proyecto para los tags"
  default     = "mean-stack"
}
variable "alb_sg_id" {
  description = "ID del Security Group del ALB"
}
