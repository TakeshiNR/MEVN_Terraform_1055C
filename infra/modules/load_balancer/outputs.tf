output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS del balanceador"
}
output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ARN del balanceador"
}
output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "ID del Security Group del ALB"
}