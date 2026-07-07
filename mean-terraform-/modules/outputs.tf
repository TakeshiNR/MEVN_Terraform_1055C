output "app_public_ip" {
  description = "IP pública del nodo de aplicación"
  value       = module.app_instance.public_ip
}

output "app_private_ip" {
  description = "IP privada del nodo de aplicación"
  value       = module.app_instance.private_ip
}

output "mongo_private_ip" {
  description = "IP privada del nodo MongoDB"
  value       = module.mongo_instance.private_ip
}

output "nat_public_ip" {
  description = "IP pública del NAT gateway usado por MongoDB"
  value       = module.network.nat_public_ip
}

output "alb_dns_name" {
  description = "DNS del balanceador de carga"
  value       = module.load_balancer.alb_dns_name
}
