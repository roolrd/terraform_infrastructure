
output "web_loadbalanser_url" {
  value = aws_elb.web.dns_name
}
