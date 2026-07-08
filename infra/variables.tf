variable "region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  default     = "us-east-1"
}
variable "project_name" {
  description = "Nombre del proyecto para etiquetar los recursos"
  default     = "mean-stack"
}
variable "instance_type" {
  description = "Tipo de instancia EC2 para app server y MongoDB"
  default     = "t2.micro"
}
variable "vpc_cidr" {
  description = "Rango de IPs de la VPC principal"
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  description = "Rango de IPs de la subnet pública"
  default     = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
  description = "Rango de IPs de la subnet privada"
  default     = "10.0.2.0/24"
}
variable "key_name" {
  description = "Nombre del key pair SSH para acceder a las instancias EC2"
}