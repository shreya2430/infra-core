# Store RDS database password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.vpc_name}-db-password-v2" # Changed name
  description             = "Database password for RDS instance"
  kms_key_id              = aws_kms_key.secrets.id
  recovery_window_in_days = 0 # Changed to 0 for immediate deletion

  tags = {
    Name        = "${var.vpc_name}-db-password"
    Environment = var.vpc_name
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# Store SendGrid API Key in Secrets Manager
resource "aws_secretsmanager_secret" "sendgrid_api_key" {
  name                    = "${var.vpc_name}-sendgrid-api-key-v2" # Changed name
  description             = "SendGrid API key for email service"
  kms_key_id              = aws_kms_key.secrets.id
  recovery_window_in_days = 0 # Changed to 0

  tags = {
    Name        = "${var.vpc_name}-sendgrid-api-key"
    Environment = var.vpc_name
  }
}

resource "aws_secretsmanager_secret_version" "sendgrid_api_key" {
  secret_id     = aws_secretsmanager_secret.sendgrid_api_key.id
  secret_string = var.sendgrid_api_key
}