

//vpc_zone_identifier  = [element(aws_subnet.public_subnets[*].id, count.index)]

resource "aws_db_subnet_group" "db_subnet_group" {
  count      = length(aws_subnet.public_subnets[*].id)
  subnet_ids = [element(aws_subnet.public_subnets[*].id, count.index)]
}

data "aws_ssm_parameter" "my_rds_password" {
  name = "dbPassword"
}

resource "aws_db_instance" "mysql" {
  identifier        = "base-mysql-rds"
  allocated_storage = 5
  //backup_retention_period   = 2
  //backup_window             = "01:00-01:30"
  //maintenance_window        = "sun:03:00-sun:03:30"
  //multi_az                  = true
  engine                 = "mysql"
  engine_version         = "8.0.16"
  instance_class         = "db.t2.micro"
  name                   = "terraform_rds"
  username               = "root"
  password               = data.aws_ssm_parameter.my_rds_password.value
  port                   = "3306"
  count                  = length(aws_subnet.public_subnets[*].id)
  db_subnet_group_name   = element(aws_subnet.public_subnets[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.rds_sg.id, aws_security_group.ecs_sg.id]
  skip_final_snapshot    = true
  //final_snapshot_identifier = "worker-final"
  publicly_accessible = true
  apply_immediately   = true
}

/*
output "rds_password" {
  value = data.aws_ssm_parameter.my_rds_password.value
}
*/
