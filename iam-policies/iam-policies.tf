# iam-policies.tf
# IAM Policies for DEV and DEMO user accounts
# These policies grant least-privilege access for deploying infrastructure

# Policy for EC2 operations
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.environment}-ec2-policy"
  description = "Policy for EC2 operations in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2InstanceManagement"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:DescribeImages",
          "ec2:DescribeKeyPairs",
          "ec2:CreateKeyPair",
          "ec2:DeleteKeyPair",
          "ec2:ImportKeyPair",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeVolumes",
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:DescribeInstanceCreditSpecifications",
          "ec2:ModifyInstanceCreditSpecification"
        ]
        Resource = "*"
      },
      {
        Sid    = "EC2SecurityGroups"
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:ModifySecurityGroupRules",
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress"
        ]
        Resource = "*"
      },
      {
        Sid    = "EC2NetworkInterfaces"
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DetachNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Policy for VPC and networking operations
resource "aws_iam_policy" "vpc_policy" {
  name        = "${var.environment}-vpc-policy"
  description = "Policy for VPC and networking operations in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VPCManagement"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:ReplaceRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeAccountAttributes"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Policy for RDS operations
resource "aws_iam_policy" "rds_policy" {
  name        = "${var.environment}-rds-policy"
  description = "Policy for RDS operations in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RDSManagement"
        Effect = "Allow"
        Action = [
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance",
          "rds:DescribeDBInstances",
          "rds:ModifyDBInstance",
          "rds:StartDBInstance",
          "rds:StopDBInstance",
          "rds:RebootDBInstance",
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBSubnetGroup",
          "rds:DescribeDBSubnetGroups",
          "rds:ModifyDBSubnetGroup",
          "rds:CreateDBParameterGroup",
          "rds:DeleteDBParameterGroup",
          "rds:DescribeDBParameterGroups",
          "rds:ModifyDBParameterGroup",
          "rds:DescribeDBParameters",
          "rds:ResetDBParameterGroup",
          "rds:DescribeDBEngineVersions",
          "rds:ListTagsForResource",
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Policy for S3 operations
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.environment}-s3-policy"
  description = "Policy for S3 operations in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketManagement"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetBucketAcl",
          "s3:PutBucketAcl",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetEncryptionConfiguration",
          "s3:PutEncryptionConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:DeleteLifecycleConfiguration",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:DeleteBucketTagging",
          "s3:GetBucketCORS",
          "s3:PutBucketCORS",
          "s3:DeleteBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetBucketLogging",
          "s3:GetReplicationConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketNotification",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetAccelerateConfiguration",
          "s3:PutAccelerateConfiguration"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3ObjectManagement"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:DeleteObjectVersion",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Policy for IAM role creation (needed for EC2 instance profiles)
resource "aws_iam_policy" "iam_policy" {
  name        = "${var.environment}-iam-policy"
  description = "Policy for IAM operations in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IAMRoleManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:ListRoleTags",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:ListInstanceProfilesForRole",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:PassRole"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMPolicyManagement"
        Effect = "Allow"
        Action = [
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion",
          "iam:TagPolicy",
          "iam:UntagPolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMGroupManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateGroup",
          "iam:DeleteGroup",
          "iam:GetGroup",
          "iam:ListGroups",
          "iam:UpdateGroup",
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup",
          "iam:GetGroupPolicy",
          "iam:ListGroupPolicies",
          "iam:AttachGroupPolicy",
          "iam:DetachGroupPolicy",
          "iam:ListAttachedGroupPolicies"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Policy for CloudWatch (monitoring and logs)
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.environment}-cloudwatch-policy"
  description = "Policy for CloudWatch operations in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy",
          "logs:TagLogGroup",
          "logs:UntagLogGroup",
          "logs:ListTagsLogGroup"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchMetrics"
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:SetAlarmState"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Policy for Route53 DNS management
resource "aws_iam_policy" "route53_policy" {
  name        = "${var.environment}-route53-policy"
  description = "Policy for Route53 DNS operations in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Route53ZoneManagement"
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListHostedZonesByName",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "Route53RecordManagement"
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "route53:GetChange"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Policy for AMI/Snapshot operations (for Packer)
resource "aws_iam_policy" "ami_policy" {
  name        = "${var.environment}-ami-policy"
  description = "Policy for AMI and snapshot operations in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AMIManagement"
        Effect = "Allow"
        Action = [
          "ec2:CreateImage",
          "ec2:DeregisterImage",
          "ec2:DescribeImages",
          "ec2:ModifyImageAttribute",
          "ec2:CopyImage",
          "ec2:RegisterImage",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:ModifySnapshotAttribute",
          "ec2:CopySnapshot"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Create IAM group for DEV environment
resource "aws_iam_group" "dev_group" {
  count = var.environment == "dev" ? 1 : 0
  name  = "dev-developers"
}

# Create IAM group for DEMO environment
resource "aws_iam_group" "demo_group" {
  count = var.environment == "demo" ? 1 : 0
  name  = "demo-developers"
}

# Local variable for group name
locals {
  group_name = var.environment == "dev" ? aws_iam_group.dev_group[0].name : aws_iam_group.demo_group[0].name
}

# Attach policies to the appropriate group
resource "aws_iam_group_policy_attachment" "ec2_attachment" {
  group      = local.group_name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_group_policy_attachment" "vpc_attachment" {
  group      = local.group_name
  policy_arn = aws_iam_policy.vpc_policy.arn
}

resource "aws_iam_group_policy_attachment" "rds_attachment" {
  group      = local.group_name
  policy_arn = aws_iam_policy.rds_policy.arn
}

resource "aws_iam_group_policy_attachment" "s3_attachment" {
  group      = local.group_name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_group_policy_attachment" "iam_attachment" {
  group      = local.group_name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_group_policy_attachment" "cloudwatch_attachment" {
  group      = local.group_name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_iam_group_policy_attachment" "route53_attachment" {
  group      = local.group_name
  policy_arn = aws_iam_policy.route53_policy.arn
}

resource "aws_iam_group_policy_attachment" "ami_attachment" {
  group      = local.group_name
  policy_arn = aws_iam_policy.ami_policy.arn
}

# Variables
variable "environment" {
  description = "Environment name (dev or demo)"
  type        = string
  validation {
    condition     = contains(["dev", "demo"], var.environment)
    error_message = "Environment must be either 'dev' or 'demo'."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile to use (dev or demo)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Outputs
output "group_name" {
  description = "Name of the IAM group created"
  value       = local.group_name
}

output "policy_arns" {
  description = "ARNs of all policies created"
  value = {
    ec2_policy        = aws_iam_policy.ec2_policy.arn
    vpc_policy        = aws_iam_policy.vpc_policy.arn
    rds_policy        = aws_iam_policy.rds_policy.arn
    s3_policy         = aws_iam_policy.s3_policy.arn
    iam_policy        = aws_iam_policy.iam_policy.arn
    cloudwatch_policy = aws_iam_policy.cloudwatch_policy.arn
    route53_policy    = aws_iam_policy.route53_policy.arn
    ami_policy        = aws_iam_policy.ami_policy.arn
  }
}

output "group_arn" {
  description = "ARN of the IAM group"
  value       = var.environment == "dev" ? aws_iam_group.dev_group[0].arn : aws_iam_group.demo_group[0].arn
}