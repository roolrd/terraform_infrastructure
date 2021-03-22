
provider "aws" {
  region = "eu-central-1"
}
#=================================
/*
terraform {
  backend "local" {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/SecurityGR/terraform.tfstate"
  }
}
*/
#===============================
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/Network/terraform.tfstate"
  }
}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

/*
output "public_ip" {
  value = chomp(data.http.icanhazip.body)
}
*/
#=========================================
resource "aws_security_group" "workstation_sg" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  name   = "Bastion-SG"
  dynamic "ingress" {
    for_each = ["80", "8080", "3306"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    //  cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = ["10.0.0.0/16", "${chomp(data.http.icanhazip.body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "SecurityGroup for WorkStation"
    Owner = "Ruslan Riznyk"
  }
}
#===================================================
resource "aws_security_group" "other_sg" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  name   = "Other-SG"
  dynamic "ingress" {
    for_each = ["80", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "${chomp(data.http.icanhazip.body)}/32"]
    //  cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "SecurityGroup for Jenkins"
    Owner = "Ruslan Riznyk"
  }
}
#==========================================
resource "aws_security_group" "web" {
  name   = "web-security-group"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  dynamic "ingress" {
    for_each = ["80", "443", "8080"]
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      //cidr_blocks = ["10.0.0.0/16"]
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    //cidr_blocks = ["10.0.0.0/16", "${chomp(data.http.icanhazip.body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "Web SecurityGroup"
    Owner = "Ruslan Riznyk"
  }
}
#========================================================
resource "aws_security_group" "rds_sg" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  name   = "RDS-SG"
  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    cidr_blocks     = ["10.0.0.0/16", "${chomp(data.http.icanhazip.body)}/32"]
    security_groups = [aws_security_group.other_sg.id, aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "RDS SecurityGroup"
    Owner = "Ruslan Riznyk"
  }
}
#=====================================================
/*
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main_base.id

  dynamic "ingress" {
    for_each = ["80", "8080", "8081"]
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
}
*/
