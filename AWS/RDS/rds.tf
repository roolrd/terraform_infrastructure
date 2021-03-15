

/*
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
  //count      = length(var.private_subnet_cidrs)
  //subnet_ids = [element(aws_subnet.private_subnets[*].id, count.index)]
  subnet_ids = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
}

data "aws_ssm_parameter" "my_rds_password" {
  name = "dbPassword"
}

resource "aws_db_instance" "mysql" {
  identifier        = "base-mysql-rds"
  allocated_storage = 5
  engine            = "mysql"
  engine_version    = "8.0.16"
  instance_class    = "db.t2.micro"
  name              = "terraform_rds"
  username          = "root"
  password          = data.aws_ssm_parameter.my_rds_password.value
  port              = "3306"
  //count                  = length(aws_db_subnet_group.rds_subnet_group[*].id)
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  //publicly_accessible = true
  apply_immediately = true
  */
/*
  s3_import {
    source_engine         = "mysql"
    source_engine_version = "8.0.16"
    bucket_name           = "base-of-product-roolrd"
    bucket_prefix         = "base_products_backup.sql"
    ingestion_role        = "arn:aws:iam::063320960030:role/role-xtrabackup-rds-restore"
  }
  */
/*
}

output "base-mysql-rds-endpoint" {
  value = aws_db_instance.mysql.endpoint
}
*/

/*
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}
output "public_ip" {
  value = "${chomp(data.http.icanhazip.body)}"
}
*/
/*
output "rds_password" {
  value = data.aws_ssm_parameter.my_rds_password.value
}
*/
