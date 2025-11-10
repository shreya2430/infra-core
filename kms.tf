# KMS Key for EC2 (EBS volumes)
resource "aws_kms_key" "ec2" {
  description             = "KMS key for EC2 EBS encryption in ${var.aws_region}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  # ADD THIS POLICY
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::648758970740:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Auto Scaling to use the key"
        Effect = "Allow"
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.vpc_name}-ec2-encryption-key"
    Environment = var.vpc_name
    Region      = var.aws_region
  }
}

resource "aws_kms_alias" "ec2" {
  name          = "alias/${var.vpc_name}-ec2-encryption"
  target_key_id = aws_kms_key.ec2.key_id
}

# KMS Key for RDS
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption in ${var.aws_region}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  tags = {
    Name        = "${var.vpc_name}-rds-encryption-key"
    Environment = var.vpc_name
    Region      = var.aws_region
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.vpc_name}-rds-encryption"
  target_key_id = aws_kms_key.rds.key_id
}

# KMS Key for S3
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 bucket encryption in ${var.aws_region}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  tags = {
    Name        = "${var.vpc_name}-s3-encryption-key"
    Environment = var.vpc_name
    Region      = var.aws_region
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.vpc_name}-s3-encryption"
  target_key_id = aws_kms_key.s3.key_id
}

# KMS Key for Secrets Manager
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager encryption in ${var.aws_region}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  tags = {
    Name        = "${var.vpc_name}-secrets-manager-encryption-key"
    Environment = var.vpc_name
    Region      = var.aws_region
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.vpc_name}-secrets-manager-encryption"
  target_key_id = aws_kms_key.secrets.key_id
}