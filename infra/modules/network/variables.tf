variable "vpc_cidr" {
  description = "ip"
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  description = "public_subnet_cidr"
  default     = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
  description = "private_subnet_cidr "
  default     = "10.0.2.0/24"
}
variable "project_name" {
  description = "project_name "
  default     = "mean-stack"
}
variable "public_subnet_cidr_2" {
  description = "Rango de IPs de la segunda subnet pública"
  default     = "10.0.3.0/24"
}