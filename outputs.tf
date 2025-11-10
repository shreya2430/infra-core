output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

# Application Security Group
output "application_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.application.id
}

# Load Balancer Security Group
output "load_balancer_security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.load_balancer.id
}

# Load Balancer
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.app.arn
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${var.domain_name}"
}

# Auto Scaling Group
output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.app.id
}

# RDS outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.csye6225.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.csye6225.port
}

# S3 outputs
output "s3_bucket_name" {
  description = "S3 bucket name for images"
  value       = aws_s3_bucket.images.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.images.arn
}

# Database security group
output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

# KMS Key outputs
output "kms_ec2_key_id" {
  description = "KMS key ID for EC2 encryption"
  value       = aws_kms_key.ec2.id
}

output "kms_rds_key_id" {
  description = "KMS key ID for RDS encryption"
  value       = aws_kms_key.rds.id
}

output "kms_s3_key_id" {
  description = "KMS key ID for S3 encryption"
  value       = aws_kms_key.s3.id
}

output "kms_secrets_key_id" {
  description = "KMS key ID for Secrets Manager encryption"
  value       = aws_kms_key.secrets.id
}
# Secrets Manager outputs
output "db_password_secret_arn" {
  description = "ARN of the database password secret"
  value       = aws_secretsmanager_secret.db_password.arn
  sensitive   = true
}

output "sendgrid_api_key_secret_arn" {
  description = "ARN of the SendGrid API key secret"
  value       = aws_secretsmanager_secret.sendgrid_api_key.arn
  sensitive   = true
}