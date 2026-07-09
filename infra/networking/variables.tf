variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo para nombrar todos los recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloque CIDR principal de la VPC"
  type        = string
}

variable "availability_zones" {
  description = "Lista de Availability Zones a usar (deben existir al menos tantas como subredes se definan)"
  type        = list(string)
}

# Usamos "map" indexado por string numerico ("0", "1", ...) en lugar de list
# para poder usar for_each (recomendado por Terraform frente a count, ya que
# evita recrear recursos si se reordena la lista).
variable "public_subnet_cidrs" {
  description = "Mapa índice -> CIDR para las subredes públicas (ALB + NAT Gateway)"
  type        = map(string)
}

variable "web_subnet_cidrs" {
  description = "Mapa índice -> CIDR para las subredes privadas de la capa web (Vue/Nginx)"
  type        = map(string)
}

variable "backend_subnet_cidrs" {
  description = "Mapa índice -> CIDR para las subredes privadas de la capa backend (Express)"
  type        = map(string)
}

variable "db_subnet_cidrs" {
  description = "Mapa índice -> CIDR para las subredes privadas de la capa de datos (MongoDB)"
  type        = map(string)
}
