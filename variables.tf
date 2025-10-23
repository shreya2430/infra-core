# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = ""
}

# VPC Configuration
variable "vpc_name" {
  description = "Name prefix for VPC and related resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (e.g., 10.0.0.0/16)"
  type        = string
}

variable "subnet_count" {
  description = "Number of public and private subnets to create"
  type        = number
  default     = 3
}

# EC2 Instance Configuration
variable "custom_ami_id" {
  description = "Custom AMI ID for EC2 instance (leave empty to use latest)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name for EC2 instance"
  type        = string
}

variable "ami_owner_id" {
  type        = string
  description = "AWS account ID that owns the custom AMI (leave empty to use current account)"
  default     = ""
}

# RDS Configuration
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "csye6225"
}

variable "db_user" {
  description = "Database master username"
  type        = string
  default     = "csye6225"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}