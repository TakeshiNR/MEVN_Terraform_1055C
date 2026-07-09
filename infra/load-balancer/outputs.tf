output "alb_dns_name" {
  description = "DNS público del balanceador de carga"
  value       = aws_lb.web_alb.dns_name
}

output "alb_arn" {
  description = "ARN del balanceador de carga"
  value       = aws_lb.web_alb.arn
}

output "target_group_arn" {
  description = "ARN del target group de la capa web"
  value       = aws_lb_target_group.web_tg.arn
}
