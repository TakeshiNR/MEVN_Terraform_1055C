output "private_ip" {
  value       = aws_instance.mongo.private_ip
  description = "IP privada de la instancia MongoDB"
}
