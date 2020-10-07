
#================Security group module===========
/*
provider "aws" {
  region = "eu-central-1"
}
*/
#------identification--my--own--public--IP-------------
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}
output "public_ip" {
  value = "${chomp(data.http.icanhazip.body)}"
}
#----OTHER WAY to get my--own--public--IP------
/*
data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

output "my_public_ip" {
  value = "${data.external.myipaddr.result.ip}"
}
*/
#----------------------------------------------------------

resource "aws_security_group" "serverSG" {
  name   = "Dynamic_security_group"
  vpc_id = var.sg_vpc_id
  //  vpc_id = "vpc-0b967232c5dc0003e"
  // depends_on = [aws_vpc.native_vpc]
  //vpc_id = data.aws_vpc.native_vpc.id
  dynamic "ingress" {
    for_each = lookup(var.allow_ports_list, var.sg_env)
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
    cidr_blocks = [
      var.cidr_blk,
    "${chomp(data.http.icanhazip.body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, { Name = "${var.sg_env}-SecurityGroup" })
}
