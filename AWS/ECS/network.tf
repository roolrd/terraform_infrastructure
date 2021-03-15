

data "aws_availability_zones" "avaliable" {}

resource "aws_vpc" "main_base" {
  cidr_block = var.cidr_blk
  tags = {
    Name = "${var.project}-Rool-VPC"
  }
}

resource "aws_internet_gateway" "main_base" {
  vpc_id = aws_vpc.main_base.id
  tags = {
    Name = "${var.project}-Rool-IGW"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main_base.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
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

#========Private Subnets and Routing=================

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_base.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.avaliable.names[2]
  tags = {
    Name = "${var.project}-private-subnet"
  }
}
/*
resource "aws_route_table" "private_subnet" {
  vpc_id = aws_vpc.main_base.id
  //route {
    //cidr_block = var.cidr_blk
    // gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.project}-route-private-subnet"
  }
}

resource "aws_route_table_association" "private_route" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_subnet.id
}
*/
