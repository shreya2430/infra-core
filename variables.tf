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

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "domain_name" {
  description = "Domain name for the environment"
  type        = string
}

# Auto Scaling Configuration
variable "asg_min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_cooldown" {
  description = "Cooldown period in seconds for Auto Scaling Group"
  type        = number
  default     = 60
}

variable "asg_health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

# Auto Scaling Policy Configuration
variable "scale_up_cpu_threshold" {
  description = "CPU threshold percentage to trigger scale up"
  type        = number
  default     = 5
}

variable "scale_down_cpu_threshold" {
  description = "CPU threshold percentage to trigger scale down"
  type        = number
  default     = 3
}

variable "scale_up_adjustment" {
  description = "Number of instances to add when scaling up"
  type        = number
  default     = 1
}

variable "scale_down_adjustment" {
  description = "Number of instances to remove when scaling down"
  type        = number
  default     = -1
}

variable "cloudwatch_evaluation_periods" {
  description = "Number of periods to evaluate for CloudWatch alarms"
  type        = number
  default     = 2
}

variable "cloudwatch_period" {
  description = "Period in seconds for CloudWatch metric evaluation"
  type        = number
  default     = 60
}

# Application Configuration
variable "app_port" {
  description = "Port on which the application runs"
  type        = number
  default     = 8080
}

# Load Balancer Configuration
variable "lb_deregistration_delay" {
  description = "Time in seconds for load balancer to wait before deregistering a target"
  type        = number
  default     = 30
}

variable "lb_health_check_interval" {
  description = "Interval in seconds between health checks"
  type        = number
  default     = 30
}

variable "lb_health_check_timeout" {
  description = "Timeout in seconds for health check"
  type        = number
  default     = 5
}

variable "lb_health_check_healthy_threshold" {
  description = "Number of consecutive health checks to consider target healthy"
  type        = number
  default     = 2
}

variable "lb_health_check_unhealthy_threshold" {
  description = "Number of consecutive health checks to consider target unhealthy"
  type        = number
  default     = 2
}

variable "lb_health_check_path" {
  description = "Path for load balancer health check"
  type        = string
  default     = "/healthz"
}