output "workstation_sg_id" {
  value = aws_security_group.other_sg.id
}

output "other_secur_gr_id" {
  value = aws_security_group.other_sg.id
}

output "rds_secur_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "web_secur_gr_id" {
  value = aws_security_group.web.id
}
