output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas (para el ALB y el NAT Gateway)"
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "web_subnet_ids" {
  description = "IDs de las subredes privadas de la capa web"
  value       = { for k, s in aws_subnet.web : k => s.id }
}

output "backend_subnet_ids" {
  description = "IDs de las subredes privadas de la capa backend"
  value       = { for k, s in aws_subnet.backend : k => s.id }
}

output "db_subnet_ids" {
  description = "IDs de las subredes privadas de la capa de base de datos"
  value       = { for k, s in aws_subnet.db : k => s.id }
}

output "nat_gateway_public_ip" {
  description = "IP pública (Elastic IP) del NAT Gateway usado por la instancia MongoDB para salir a Internet"
  value       = aws_eip.nat.public_ip
}
