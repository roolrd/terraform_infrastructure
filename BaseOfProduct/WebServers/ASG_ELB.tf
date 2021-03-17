

resource "aws_launch_configuration" "web" {
  name_prefix     = "WEB-Server-LC-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.other_sg.id]
  //key_name        = "mcdzk-frankfurt-key"
  //user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  load_balancers       = [aws_elb.web.name]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "web" {
  name = "WebServer-ELB"
  //  count              = length(var.public_subnet_cidrs)
  //  availability_zones = data.aws_availability_zones.avaliable.names[count.index]
  availability_zones = [data.aws_availability_zones.avaliable.names[0], data.data.aws_availability_zones.avaliable.names[1]]
  security_groups    = [aws_security_group.elb_sg.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-ELB"
  }
}
