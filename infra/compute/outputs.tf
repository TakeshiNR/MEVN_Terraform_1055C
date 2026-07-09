output "instance_ids" {
  description = "IDs de las instancias creadas en esta capa"
  value       = { for k, i in aws_instance.this : k => i.id }
}

output "private_ips" {
  description = "IPs privadas de las instancias de esta capa"
  value       = { for k, i in aws_instance.this : k => i.private_ip }
}

output "public_ips" {
  description = "IPs publicas de las instancias de esta capa (vacio '' si no tienen IP publica asignada)"
  value       = { for k, i in aws_instance.this : k => i.public_ip }
}
