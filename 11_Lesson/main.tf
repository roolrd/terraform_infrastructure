
provider "aws" {
  region = "eu-central-1"
}
#==========Network==================
data "aws_availability_zones" "avaliable" {}

data "aws_vpc" "web_vpc" {
  tags = {
    Name = "base-Rool-VPC"
  }
}

data "aws_internet_gateway" "main_base" {
  tags = {
    Name = "base-Rool-IGW"
  }
}

resource "aws_subnet" "web_public_subnets" {
  count                   = length(var.web_public_subnet_cidrs)
  vpc_id                  = data.aws_vpc.main_base.id
  cidr_block              = element(var.web_public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.avaliable.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-Rool-web-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "web_public_subnets" {
  vpc_id = data.aws_vpc.main_base.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.main_base.internet_gateway_id
  }
  tags = {
    Name = "${var.project}-route-public-subnet"
  }
}

resource "aws_route_table_association" "web_route_subnet" {
  count          = length(aws_subnet.web_public_subnets[*].id)
  subnet_id      = element(aws_subnet.web_public_subnets[*].id, count.index)
  route_table_id = aws_route_table.web_public_subnets.id
}

#============Servers======================

data "aws_ami" "latest_aws_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#----------------------------------------------------
resource "aws_security_group" "web" {
  name = "Dynamic_security_group"

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "Dynamic SecurityGroup"
    Owner = "Ruslan Riznyk"
  }
}

resource "aws_launch_configuration" "web" {
  //  name            = "Webserver-LaunchConfig"
  name_prefix     = "Webserver-LaunchConfig-"
  image_id        = data.aws_ami.latest_aws_linux_2.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web.id]
  user_data       = file("./user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                 = "AutoScalingGr with ${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.web.name]
  dynamic "tag" {
    for_each = {
      Name   = "Webserver in ASG"
      Owner  = "Ruslan Riznyk"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "web" {
  name               = "Webserver-HA-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.web.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "Webserver-HA-ELB"
  }
}

/*
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}
*/
