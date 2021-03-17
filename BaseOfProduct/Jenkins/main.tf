#============================
Script for Jenkins
#============================

provider "aws" {
  region = "eu-central-1"
}

#===============================
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}
output "public_ip" {
  value = chomp(data.http.icanhazip.body)
}
#==============================

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_network_interface" "jenkins_server_ip" {
  subnet_id   = aws_subnet.public_subnets[0].id
  private_ips = ["10.0.11.100/24"]
}

resource "aws_network_interface" "jenkins_node1_ip" {
  subnet_id   = aws_subnet.public_subnets[0].id
  private_ips = ["10.0.11.101/24"]
}

resource "aws_instance" "jenkins_server" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.latest_amazon_linux.id
  vpc_security_group_ids = [aws_security_group.other_sg.id]
  network_interface {
    network_interface_id = aws_network_interface.jenkins_server_ip.id
    device_index         = 0
  }
  key_name = "mcdzk-frankfurt-key"
  tags = {
    Name     = "Jenkins Server"
    Avaliabl = "SubNet-Public-0 SGroup Other"
  }
}

resource "aws_instance" "jenkins_node_1" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.latest_amazon_linux.id
  vpc_security_group_ids = [aws_security_group.other_sg.id]
  network_interface {
    network_interface_id = aws_network_interface.jenkins_node1_ip.id
    device_index         = 0
  }
  //  user_data              = file("jenkinsNodeinstall.sh")
  tags = {
    Name     = "Jenkins Node 1"
    Avaliabl = "SubNet-Privat SGroup others"
  }
}

/*
terraform {
  backend "s3" {
    bucket = "base-of-product-roolrd"
    key    = "RDS/terraform.tfstate"
    region = "eu-central-1"
  }
}
*/
