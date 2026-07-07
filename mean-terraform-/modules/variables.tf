variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR of main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_a" {
  description = "CIDR of public subnet A"
  type        = string
  default     = "10.0.10.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR of public subnet B"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR of private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type_app" {
  type        = string
  default     = "t3.micro"
}

variable "instance_type_mongo" {
  type        = string
  default     = "t3.micro"
}

variable "app_ami_id" {
  default = "ami-06067086cf86c58e6"
}

variable "mongo_ami_id" {
  default = "ami-0b6d9d3d33ba97d99"
}

variable "key_pair_name" {
  type        = string
  default     = "mean-keypair"
}
