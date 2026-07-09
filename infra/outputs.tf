# =============================================================================
# OUTPUTS
# -----------------------------------------------------------------------------
#   - IP publicas/privadas de cada nodo
#   - DNS del balanceador
#   - IP publica del NAT Gateway (usada por la instancia MongoDB para salir)
#
# Nota: las instancias web/backend/db estan en subredes PRIVADAS (solo el ALB
# es publico), por lo que su "IP publica" es null.
# =============================================================================

# -----------------------------------------------------------------------------
# IPs PRIVADAS de cada nodo
# -----------------------------------------------------------------------------
output "web_private_ips" {
  description = "IPs privadas de las instancias de la capa web"
  value       = module.web_instances.private_ips
}

output "backend_private_ips" {
  description = "IPs privadas de las instancias de la capa backend"
  value       = module.backend_instances.private_ips
}

output "db_private_ip" {
  description = "IP privada de la instancia MongoDB"
  value       = module.mongodb.private_ip
}

# -----------------------------------------------------------------------------
# IPs PUBLICAS de cada nodo
# En este diseño ninguna instancia individual tiene IP publica directa (todo
# el trafico entrante pasa por el ALB); por eso los valores apareceran vacios.
# -----------------------------------------------------------------------------
output "web_public_ips" {
  description = "IPs publicas de las instancias de la capa web (vacio si la subred es privada)"
  value       = module.web_instances.public_ips
}

output "backend_public_ips" {
  description = "IPs publicas de las instancias de la capa backend (vacio si la subred es privada)"
  value       = module.backend_instances.public_ips
}

# -----------------------------------------------------------------------------
# DNS del balanceador
# -----------------------------------------------------------------------------
output "load_balancer_dns" {
  description = "DNS publico del balanceador de carga (ALB) - punto de entrada de la aplicacion"
  value       = module.load_balancer.alb_dns_name
}

# -----------------------------------------------------------------------------
# IP publica del NAT Gateway usada por la instancia MongoDB para salir a Internet
# -----------------------------------------------------------------------------
output "nat_gateway_public_ip" {
  description = "IP publica (Elastic IP) del NAT Gateway por la que sale el trafico de la instancia MongoDB"
  value       = module.networking.nat_gateway_public_ip
}

# -----------------------------------------------------------------------------
# Bucket de artefactos (frontend/backend empaquetados)
# -----------------------------------------------------------------------------
output "artifacts_bucket" {
  description = "Nombre del bucket S3 donde se suben frontend.zip / backend.zip"
  value       = aws_s3_bucket.artifacts.id
}
