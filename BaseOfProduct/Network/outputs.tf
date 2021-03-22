output "vpc_id" {
  value = aws_vpc.main_base.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "Web_public_subnet_ids" {
  value = aws_subnet.web_public_subnets[*].id
}

output "IGW_id" {
  value = aws_internet_gateway.main_base.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

/*
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
*/
