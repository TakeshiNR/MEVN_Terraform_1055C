variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo para nombrar los security groups"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se crean los security groups"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR (IP publica del administrador, ej: 190.12.34.56/32) autorizado para SSH"
  type        = string
}

variable "backend_port" {
  description = "Puerto en el que escucha la API de Express"
  type        = number
  default     = 3000
}
