variable "vpc_id" {
  description = "ID de la VPC principal"
}
variable "public_subnet_id" {
  description = "ID de la subnet publica donde vive app server"
}
variable "app_server_id" {
  description = "ID del app server"
}
variable "project_name" {
  description = "Nombre del proyecto para los tags"
  default     = "mean-stack"
}
variable "public_subnet_id_2" {
  description = "ID de la segunda subnet pública para el ALB"
}
