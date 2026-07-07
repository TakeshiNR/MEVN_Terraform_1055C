output "instance_id" {
  value       = aws_instance.app.id
  description = "ID de la instancia de aplicación"
}

output "public_ip" {
  value       = aws_instance.app.public_ip
  description = "IP pública de la instancia de aplicación"
}

output "private_ip" {
  value       = aws_instance.app.private_ip
  description = "IP privada de la instancia de aplicación"
}
