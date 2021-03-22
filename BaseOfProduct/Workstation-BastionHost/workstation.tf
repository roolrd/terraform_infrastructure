provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "local" {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/Workstation-BastionHost/terraform.tfstate"
  }
}
#=========================================
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

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}
#==========================================
resource "aws_network_interface" "n_ubuntu_ip" {
  subnet_id       = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  security_groups = [data.terraform_remote_state.secur_gr.outputs.workstation_sg_id]
  private_ips     = ["10.0.10.100"]
}

resource "aws_instance" "workstation" {
  instance_type           = "t2.micro"
  ami                     = "ami-0bef5e4309902677d"
  key_name                = "mcdzk-frankfurt-key"
  disable_api_termination = true
  network_interface {
    network_interface_id = aws_network_interface.n_ubuntu_ip.id
    device_index         = 0
  }
  tags = {
    Name = "n-Ubuntu-16.04"

  }
}
