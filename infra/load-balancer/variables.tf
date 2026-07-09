variable "project_name" {
  description = "Nombre del proyecto (prefijo de nombres)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se crea el ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "Mapa índice -> subnet_id de las subredes PUBLICAS donde se despliega el ALB"
  type        = map(string)
}

variable "alb_security_group_id" {
  description = "ID del security group a asociar al ALB"
  type        = string
}

variable "web_instance_ids" {
  description = "Mapa índice -> instance_id de las instancias de la capa web a registrar en el target group"
  type        = map(string)
}
