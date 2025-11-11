# DynamoDB Table for Email Tracking (deduplication)
resource "aws_dynamodb_table" "email_tracking" {
  name         = "${var.vpc_name}-email-tracking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "emailToken"

  attribute {
    name = "emailToken"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = "${var.vpc_name}-email-tracking"
    Environment = var.vpc_name
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.vpc_name}-lambda-email-verification-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.vpc_name}-lambda-role"
    Environment = var.vpc_name
  }
}

# IAM Policy for Lambda to access DynamoDB
resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${var.vpc_name}-lambda-dynamodb-policy"
  description = "Policy for Lambda to access DynamoDB for email tracking"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.email_tracking.arn
      }
    ]
  })
}

# IAM Policy for Lambda to access Secrets Manager
resource "aws_iam_policy" "lambda_secrets" {
  name        = "${var.vpc_name}-lambda-secrets-policy"
  description = "Policy for Lambda to access SendGrid API key from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.sendgrid_api_key.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.secrets.arn
      }
    ]
  })
}

# Attach policies to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_secrets.arn
}

# Lambda Function (placeholder - code uploaded via CI/CD)
resource "aws_lambda_function" "email_verification" {
  function_name = "email-verification-service"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "src/index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  memory_size   = 256

  # Placeholder code - will be replaced by CI/CD
  filename         = "${path.module}/lambda-placeholder.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-placeholder.zip")

  environment {
    variables = {
      SENDGRID_API_KEY    = var.sendgrid_api_key
      FROM_EMAIL          = "noreply@${var.domain_name}"
      DOMAIN              = var.domain_name
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.email_tracking.name
    }
  }

  tags = {
    Name        = "${var.vpc_name}-email-verification-lambda"
    Environment = var.vpc_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_dynamodb,
    aws_iam_role_policy_attachment.lambda_secrets
  ]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.email_verification.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.vpc_name}-lambda-logs"
    Environment = var.vpc_name
  }
}