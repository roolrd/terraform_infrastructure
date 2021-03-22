
output "rds_endpoint" {
  value = data.aws_db_instance.mysql.address
}
