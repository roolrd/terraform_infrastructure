
provider "aws" {
  region = "eu-central-1"
}
/*
terraform {
  backend "local" {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/Network/terraform.tfstate"
  }
}
*/
data "aws_availability_zones" "avaliable" {}

resource "aws_vpc" "main_base" {
  cidr_block = var.cidr_blk
  tags = {
    Name = "base-Rool-VPC"
  }
}

resource "aws_internet_gateway" "main_base" {
  vpc_id = aws_vpc.main_base.id
  tags = {
    Name = "base-Rool-IGW"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main_base.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.avaliable.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-Rool-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main_base.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_base.id
  }
  tags = {
    Name = "${var.project}-route-public-subnet"
  }
}

resource "aws_route_table_association" "route_subnet" {
  count          = length(aws_subnet.public_subnets[*].id)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_subnets.id
}
#=============Web Public Subnets====================
resource "aws_subnet" "web_public_subnets" {
  count                   = length(var.web_public_subnet_cidrs)
  vpc_id                  = aws_vpc.main_base.id
  cidr_block              = element(var.web_public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.avaliable.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-Rool-web-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "web_public_subnets" {
  vpc_id = aws_vpc.main_base.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_base.id
  }
  tags = {
    Name = "${var.project}-route-web-public-subnet"
  }
}

resource "aws_route_table_association" "web_route_subnet" {
  count          = length(aws_subnet.web_public_subnets[*].id)
  subnet_id      = element(aws_subnet.web_public_subnets[*].id, count.index)
  route_table_id = aws_route_table.web_public_subnets.id
}
#========Private Subnets and Routing=================

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main_base.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.avaliable.names[count.index]
  tags = {
    Name = "${var.project}-Rool-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  vpc_id = aws_vpc.main_base.id
  //route {
  //cidr_block = var.cidr_blk
  // gateway_id = aws_nat_gateway.nat[count.index].id

  tags = {
    Name = "${var.project}-route-private-subnet"
  }
}

resource "aws_route_table_association" "private_route" {
  count          = length(aws_subnet.private_subnets[*].id)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_subnets.id
}
