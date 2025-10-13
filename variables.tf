variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name prefix for VPC and related resources"
  type        = string
  default     = "main"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
}

# EC2 Instance Variables
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
  default     = ""
}

# Database Variables
variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "csye6225"
}

variable "db_user" {
  description = "PostgreSQL database user"
  type        = string
  default     = "csye6225"
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}