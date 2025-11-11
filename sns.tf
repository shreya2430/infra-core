# SNS Topic for user verification emails
resource "aws_sns_topic" "user_verification" {
  name = "${var.vpc_name}-user-verification"

  tags = {
    Name        = "${var.vpc_name}-user-verification"
    Environment = var.vpc_name
  }
}

# SNS Topic Subscription - Lambda
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.user_verification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification.arn
}

# Lambda permission to allow SNS to invoke it
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_verification.arn
}

# IAM Policy for EC2 to publish to SNS
resource "aws_iam_policy" "sns_publish" {
  name        = "${var.vpc_name}-sns-publish-policy"
  description = "Policy for EC2 to publish messages to SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.user_verification.arn
      }
    ]
  })
}

# Attach SNS policy to EC2 role
resource "aws_iam_role_policy_attachment" "ec2_sns_publish" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = aws_iam_policy.sns_publish.arn
}