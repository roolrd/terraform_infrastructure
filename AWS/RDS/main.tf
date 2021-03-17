provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "base-of-product-roolrd"
    key    = "RDS/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


/*
resource "aws_instance" "jenkins_server" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.latest_amazon_linux.id
  vpc_security_group_ids = [aws_security_group.other_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id
  key_name               = "mcdzk-frankfurt-key"
  tags = {
    Name     = "Jenkins Server"
    Avaliabl = "SubNet-Public-0 SGroup Other"
  }
}

resource "aws_instance" "jenkins_node_1" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.latest_amazon_linux.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id
  tags = {
    Name     = "Jenkins Node 1"
    Avaliabl = "SubNet-Public-0 SGroup RDS"
  }
}
*/
resource "aws_instance" "docker_node_1" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.latest_amazon_linux.id
  vpc_security_group_ids = [aws_security_group.other_sg.id]
  subnet_id              = aws_subnet.private_subnets[0].id
  key_name               = "mcdzk-frankfurt-key"
  tags = {
    Name     = "Docker Node 1"
    Avaliabl = "SubNet-Privat SGroup others"
  }
}
/*
resource "aws_instance" "docker_node_2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.latest_amazon_linux.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_id              = aws_subnet.private_subnets[0].id
  tags = {
    Name     = "Docker Node 2"
    Avaliabl = "SubNet-Privat SGroup RDS"
  }
}
*/
resource "aws_instance" "docker_node_3" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.latest_amazon_linux.id
  vpc_security_group_ids = [aws_security_group.other_sg.id]
  subnet_id              = aws_subnet.private_subnets[1].id
  key_name               = "mcdzk-frankfurt-key"
  tags = {
    Name     = "Docker Node 3"
    Avaliabl = "SubNet-Private-1 SGroup Other"
  }
}
