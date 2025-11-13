# Generate random UUID for S3 bucket name
resource "random_uuid" "s3_bucket" {}

# S3 Bucket for storing images
resource "aws_s3_bucket" "images" {
  bucket        = random_uuid.s3_bucket.result
  force_destroy = true

  tags = {
    Name = "${var.vpc_name}-images-bucket"
  }
}

# Enable default encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms" # CHANGED from AES256
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true #for cost optimization
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy - transition to STANDARD_IA after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"

    filter {
      prefix = "" # Apply to all objects
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}