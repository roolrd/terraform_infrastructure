provider "aws" {
  region = "eu-central-1"
}

#=======Module for creating VPC Network====

data "aws_availability_zones" "avaliable" {}
#========================================
resource "aws_vpc" "main" {
  cidr_block = var.cidr_blk
  tags = {
    Name = "${var.environment}-Rool-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-Rool-IGW"
  }
}
#======Public subnets and Routing=========

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = data.aws_availability_zones.avaliable.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-Rool-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.environment}-route-public-subnet"
  }
}

resource "aws_route_table_association" "public_route" {
  count          = length(aws_subnet.public_subnets[*].id)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_subnets.id
}

#==========NAT Gateways with Elastic IPs===============

resource "aws_eip" "eip_for_nat" {
  count = length(var.private_subnet_cidr)
  vpc   = true
  tags = {
    Name = "${var.environment}-elastic-ip-nat-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidr)
  allocation_id = aws_eip.eip_for_nat[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
  tags = {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }
}

#========Private Subnets and Routing=================

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = data.aws_availability_zones.avaliable.names[count.index]
  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.environment}-route-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_route" {
  count          = length(aws_subnet.private_subnets[*].id)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_subnets[count.index].id
}
