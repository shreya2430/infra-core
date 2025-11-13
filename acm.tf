# Data source to get ACM certificate
data "aws_acm_certificate" "ssl_cert" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}