#============================
#=====Script for Jenkins
#============================

provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "local" {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/Jenkins/terraform.tfstate"
  }
}
#===============================
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/Network/terraform.tfstate"
  }
}

data "terraform_remote_state" "secur_gr" {
  backend = "local"

  config = {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/SecurityGR/terraform.tfstate"
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
#==============================

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.jenkins_server.id
  tags = {
    Name = "Jenkis Server EIP"
  }
}

resource "aws_network_interface" "jenkins_server_ip" {
  subnet_id       = data.terraform_remote_state.network.outputs.public_subnet_ids[1]
  security_groups = [data.terraform_remote_state.secur_gr.outputs.other_secur_gr_id]
  private_ips     = ["10.0.11.100"]
}

resource "aws_instance" "jenkins_server" {
  instance_type           = "t2.micro"
  ami                     = "ami-0dcdbec70a2fb755b"
  key_name                = "Jenkins"
  disable_api_termination = true
  network_interface {
    network_interface_id = aws_network_interface.jenkins_server_ip.id
    device_index         = 0
  }
  tags = {
    Name      = "Jenkins-Server"
    Avaliable = "SubNet-Public-1 SGroup Other"
  }


  //provisioner "remote-exec" {
  //  inline = ["sudo yum install python37 -y"]
  //}

  //provisioner "local-exec" {
  //  command = "ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ${var.ssh_key_private} provision.yml"
  //  }
}

resource "aws_network_interface" "jenkins_node1_ip" {
  subnet_id       = data.terraform_remote_state.network.outputs.public_subnet_ids[1]
  security_groups = [data.terraform_remote_state.secur_gr.outputs.other_secur_gr_id]
  private_ips     = ["10.0.11.101"]
}

resource "aws_instance" "jenkins_node_1" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.latest_amazon_linux.id
  network_interface {
    network_interface_id = aws_network_interface.jenkins_node1_ip.id
    device_index         = 0
  }
  key_name  = "Jenkins"
  user_data = file("jenkinsNodeinstall.sh")
  tags = {
    Name     = "Jenkins-Node"
    Position = "1"
  }
}
