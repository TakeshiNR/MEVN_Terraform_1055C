output "alb_sg_id" {
  description = "ID del security group del ALB"
  value       = aws_security_group.alb.id
}

output "web_sg_id" {
  description = "ID del security group de la capa web"
  value       = aws_security_group.web.id
}

output "backend_sg_id" {
  description = "ID del security group de la capa backend"
  value       = aws_security_group.backend.id
}
