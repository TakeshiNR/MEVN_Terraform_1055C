output "instance_id" {
  value       = aws_instance.mongodb.id
  description = "ID de la instancia EC2 de MongoDB"
}
output "private_ip" {
  value       = aws_instance.mongodb.private_ip
  description = "IP privada de la instancia MongoDB"
}
output "security_group_id" {
  value       = aws_security_group.mongodb.id
  description = "ID del Security Group de MongoDB"
}