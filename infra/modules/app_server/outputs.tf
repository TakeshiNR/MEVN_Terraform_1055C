output "instance_id" {
  value       = aws_instance.app_server.id
  description = "ID de la instancia EC2 de app server"
}
output "public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "IP publica del app server"
}
output "security_group_id" {
  value       = aws_security_group.app_server.id
  description = "ID del Security Group de app server"
}