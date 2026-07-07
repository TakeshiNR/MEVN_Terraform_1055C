variable "vpc_id" {
  type        = string
  description = "ID de la VPC donde se creara el ALB"
}

variable "public_subnets" {
  type        = list(string)
  description = "Lista de subredes publicas para el ALB"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group del ALB"
}

variable "app_instance_id" {
  type        = string
  description = "ID de la instancia de aplicacion que sera target del ALB"
}
