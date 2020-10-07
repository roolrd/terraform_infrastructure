
output "vpc-id" { value = aws_vpc.main.id }

output "vpc-cidr" { value = aws_vpc.main.cidr_block }

output "public_subnet_cidr_block" {
  value = aws_subnet.public_subnets[*].cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}
