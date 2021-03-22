
provider "aws" {
  region = "eu-central-1"
}
#========================================
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
#=========================================================

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [data.terraform_remote_state.network.outputs.private_subnet_ids[0], data.terraform_remote_state.network.outputs.private_subnet_ids[1]]
}

data "aws_ssm_parameter" "my_rds_password" {
  name = "dbPassword"
}

resource "aws_db_instance" "mysql" {
  identifier        = "base-mysql-rds"
  allocated_storage = 5
  engine            = "mysql"
  engine_version    = "8.0.16"
  //engine_version = "8.0.20"
  instance_class         = "db.t2.micro"
  name                   = "terraform_rds"
  username               = "root"
  password               = data.aws_ssm_parameter.my_rds_password.value
  port                   = "3306"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [data.terraform_remote_state.secur_gr.outputs.rds_secur_sg_id]
  skip_final_snapshot    = true
  apply_immediately      = true
}

data "aws_db_instance" "mysql" {
  db_instance_identifier = "base-mysql-rds"
}
/*
output "base-mysql-rds-endpoint" {
  value = aws_db_instance.mysql.endpoint
}

provider "mysql" {
  endpoint = aws_db_instance.mysql.endpoint
  username = "root"
  password = data.aws_ssm_parameter.my_rds_password.value
}
resource "mysql_database" "app" {
  name = "another_db"
}
*/

/*
    provisioner "file" {
    source      = "base_products_backup.sql"
    destination = "~/base_products_backup.sql"

  }
  provisioner "remote-exec" {
  when = create
  inline = [
  "mysql < base_products_backup.sql",
  ]
  }
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
