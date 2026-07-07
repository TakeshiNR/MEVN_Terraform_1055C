variable "vpc_cidr" {
  type        = string
  description = "CIDR de la VPC"
}

variable "public_subnet_cidr_a" {
  type        = string
  description = "CIDR de la subred publica A"
}

variable "public_subnet_cidr_b" {
  type        = string
  description = "CIDR de la subred publica B"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR de la subred privada"
}

variable "aws_region" {
  type        = string
  description = "Region AWS"
}

