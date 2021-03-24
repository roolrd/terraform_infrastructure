
provider "aws" {
  region = "eu-central-1"
}


terraform {
  backend "local" {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/WebServers/terraform.tfstate"
  }
}

#==========Network and Security groups==================

data "aws_availability_zones" "work" {}

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

data "terraform_remote_state" "rds" {
  backend = "local"

  config = {
    path = "D:/DevOps/TERRAFORM/terraform_modules/BaseOfProduct/RDS/terraform.tfstate"
  }
}

data "aws_vpc" "web_base" {
  tags = {
    Name = "base-Rool-VPC"
  }
}

data "aws_internet_gateway" "web_base" {
  tags = {
    Name = "base-Rool-IGW"
  }
}

#==============Create launchConfiguration with bootstarapped ec2_instance===
data "aws_ami" "latest_aws_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ssm_parameter" "my_rds_password" {
  name = "dbPassword"
}

resource "aws_launch_configuration" "web" {
  name_prefix     = "Web-LaunchConfig-"
  image_id        = data.aws_ami.latest_aws_linux_2.id
  instance_type   = "t2.micro"
  security_groups = [data.terraform_remote_state.secur_gr.outputs.web_secur_gr_id]
  key_name        = "Web_servers"
  user_data = templatefile("user_data.sh.tpl", { pass = data.aws_ssm_parameter.my_rds_password.value,
  dburl = data.terraform_remote_state.rds.outputs.rds_endpoint })
  lifecycle {
    create_before_destroy = true
  }
}

#=========================================================================
resource "aws_autoscaling_group" "web" {
  name                 = "ASG-with-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 3
  max_size             = 5
  min_elb_capacity     = 3
  health_check_type    = "ELB"
  vpc_zone_identifier = [data.terraform_remote_state.network.outputs.Web_public_subnet_ids[0],
    data.terraform_remote_state.network.outputs.Web_public_subnet_ids[1],
  data.terraform_remote_state.network.outputs.Web_public_subnet_ids[2]]
  // vpc_zone_identifier = [data.terraform_remote_state.network.outputs.private_subnet_ids[0],
  // data.terraform_remote_state.network.outputs.private_subnet_ids[1],
  //  data.terraform_remote_state.network.outputs.private_subnet_ids[2]]
  load_balancers = [aws_elb.web.name]
  dynamic "tag" {
    for_each = {
      Name  = "Webserver in ASG"
      Owner = "Ruslan Riznyk"
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
  name = "webserver-elb"
  subnets = [data.terraform_remote_state.network.outputs.Web_public_subnet_ids[0],
    data.terraform_remote_state.network.outputs.Web_public_subnet_ids[1],
  data.terraform_remote_state.network.outputs.Web_public_subnet_ids[2]]
  // subnets         = [data.terraform_remote_state.network.outputs.private_subnet_ids[0],
  // data.terraform_remote_state.network.outputs.private_subnet_ids[1],
  //  data.terraform_remote_state.network.outputs.private_subnet_ids[2]]
  security_groups = [data.terraform_remote_state.secur_gr.outputs.web_secur_gr_id]
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
    Name = "Webserver-ELB"
  }
}

resource "aws_network_interface" "dev_server" {
  subnet_id       = data.terraform_remote_state.network.outputs.Web_public_subnet_ids[0]
  security_groups = [data.terraform_remote_state.secur_gr.outputs.web_secur_gr_id]
  private_ips     = ["10.0.30.101"]
}

resource "aws_instance" "dev_server" {
  ami           = data.aws_ami.latest_aws_linux_2.id
  instance_type = "t2.micro"
  //subnet_id       = data.terraform_remote_state.network.outputs.Web_public_subnet_ids[0]
  //security_groups = [data.terraform_remote_state.secur_gr.outputs.web_secur_gr_id]
  key_name = "Web_servers"
  user_data = templatefile("user_data.sh.tpl", { pass = data.aws_ssm_parameter.my_rds_password.value,
  dburl = data.terraform_remote_state.rds.outputs.rds_endpoint })

  network_interface {
    network_interface_id = aws_network_interface.dev_server.id
    device_index         = 0
  }

  tags = {
    Name = "dev-web-server"

  }
}
