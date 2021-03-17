
output "vpc-id" {
  value = aws_vpc.main_base.id
}

output "vpc-cidr" {
  value = aws_vpc.main_base.cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.public_subnets[*].id
}
