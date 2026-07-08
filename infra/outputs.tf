output "app_server_public_ip" {
  value       = module.app_server.public_ip
  description = "IP publica del app server"
}
output "mongodb_private_ip" {
  value       = module.mongodb.private_ip
  description = "IP privada de la instancia MongoDB"
}
output "alb_dns_name" {
  value       = module.load_balancer.alb_dns_name
  description = "DNS del balanceador"
}
output "nat_gateway_ip" {
  value       = module.network.nat_gateway_id
  description = "IP pública del NAT Gateway"
}
output "app_server_instance_id" {
  value       = module.app_server.instance_id
  description = "ID de la instancia EC2 de app server"
}