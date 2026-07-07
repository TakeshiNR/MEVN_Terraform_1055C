output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "nat_public_ip" {
  value = aws_eip.nat_eip.public_ip
}

