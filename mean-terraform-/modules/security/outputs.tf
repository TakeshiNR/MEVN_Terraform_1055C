output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "ID del SG del ALB"
}

output "app_sg_id" {
  value       = aws_security_group.app_sg.id
  description = "ID del SG de la aplicación"
}

output "mongo_sg_id" {
  value       = aws_security_group.mongo_sg.id
  description = "ID del SG de MongoDB"
}
