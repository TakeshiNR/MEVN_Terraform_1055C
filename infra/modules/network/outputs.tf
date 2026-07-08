output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID de la VPC principal"
}
output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "ID de subnet publica"
}
output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "ID de subnet privada"
}
output "nat_gateway_id" {
  value       = aws_nat_gateway.main.id
  description = "ID de la Nat"
}
output "public_subnet_id_2" {
  value       = aws_subnet.public_2.id
  description = "ID de la segunda subnet pública"
}