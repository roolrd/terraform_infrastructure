resource "aws_launch_configuration" "bastion" {
  //name            = "Bastion Host"
  name_prefix     = "Bastion Host-LC-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.bastion_sg.id]
  key_name        = "mcdzk-frankfurt-key"
  //user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  name                 = "ASG-${aws_launch_configuration.bastion.name}"
  launch_configuration = aws_launch_configuration.bastion.name
  min_size             = 1
  max_size             = 1
  //  min_elb_capacity     = 2
  //  health_check_type    = "ELB"
  vpc_zone_identifier = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  //  load_balancers       = [aws_elb.web.name]

  lifecycle {
    create_before_destroy = true
  }
}
