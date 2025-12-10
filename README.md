# AWS Cloud Infrastructure - Terraform

Production-grade AWS infrastructure automation using Infrastructure as Code (IaC) with Terraform. This repository provisions a complete cloud environment including VPC, auto-scaling EC2 instances, RDS database, S3 storage, load balancing, and comprehensive monitoring.

## Architecture Overview

This Terraform configuration creates a highly available, auto-scaling cloud infrastructure on AWS featuring:
- Custom VPC with public/private subnets across multiple availability zones
- Application Load Balancer with SSL/TLS termination
- Auto Scaling Groups with CloudWatch-based policies (2-6 instances)
- RDS PostgreSQL with Multi-AZ deployment and automated backups
- S3 buckets for application storage
- Route 53 DNS configuration with health checks
- CloudWatch monitoring, alarms, and logging
- SNS topics for email notifications
- IAM roles and security groups following least privilege principle

**Related Repositories:**
- [Web Application](https://github.com/shreya2430/webapp) - Spring Boot REST API
- [Serverless](https://github.com/shreya2430/lambda-email-verification) - Email verification system

## What Gets Provisioned

### Networking
- **VPC:** Custom Virtual Private Cloud with configurable CIDR block
- **Subnets:** Public and private subnets across 3 availability zones
- **Internet Gateway:** For public subnet internet access
- **Route Tables:** Separate routing for public and private subnets
- **Security Groups:** Granular access control for ALB, EC2, and RDS

### Compute & Auto-Scaling
- **Launch Template:** AMI configuration with user data scripts
- **Auto Scaling Group:** Dynamic scaling between 2-6 instances
- **Application Load Balancer:** HTTPS traffic distribution with health checks
- **Target Groups:** Instance registration and health monitoring
- **Scaling Policies:** CPU-based scale-up and scale-down policies

### Database
- **RDS PostgreSQL:** Multi-AZ deployment with automated backups
- **Parameter Group:** Optimized database configuration
- **Subnet Group:** Private subnet placement
- **Encryption:** Data at rest encryption with KMS
- **Security Group:** Database access restricted to EC2 instances

### Storage
- **S3 Bucket:** Application file storage with lifecycle policies
- **IAM Roles:** EC2 instance roles for S3 access
- **Bucket Policies:** Secure access control

### DNS & SSL/TLS
- **Route 53:** A record for domain routing to ALB
- **ACM Certificate:** SSL/TLS certificate for HTTPS
- **Health Checks:** DNS failover configuration

### Monitoring & Notifications
- **CloudWatch Log Groups:** Application and system logs
- **CloudWatch Alarms:** CPU, memory, and custom metrics
- **SNS Topics:** Email notifications for user verification
- **Custom Metrics:** Application-specific monitoring

### Security & Secrets
- **IAM Roles:** EC2 instance profiles with minimal permissions
- **KMS Keys:** Encryption for RDS, EBS, and S3
- **Secrets Manager:** Database credentials management
- **Security Groups:** Network-level access control

## Prerequisites

- **Terraform:** v1.0+ 
- **AWS CLI:** v2.0+ configured with profiles
- **AWS Account:** Dev and Demo accounts configured
- **SSH Key Pair:** For EC2 instance access
- **Custom AMI:** Built with Packer containing your application
- **SSL Certificate:** Imported to ACM (for DEMO environment)

## Getting Started

### 1. Configure AWS Profiles

Ensure you have AWS CLI profiles configured:
```bash
# ~/.aws/credentials
[dev]
aws_access_key_id = YOUR_DEV_ACCESS_KEY
aws_secret_access_key = YOUR_DEV_SECRET_KEY

[demo]
aws_access_key_id = YOUR_DEMO_ACCESS_KEY
aws_secret_access_key = YOUR_DEMO_SECRET_KEY

# ~/.aws/config
[profile dev]
region = us-east-1
output = json

[profile demo]
region = us-east-1
output = json
```

### 2. Clone Repository
```bash
git clone https://github.com/shreya2430/infra-core
cd tf-aws-infra
```

### 3. Initialize Terraform
```bash
terraform init
```

This downloads required providers and sets up the backend.

## Configuration

### Variables

All configurable variables are defined in `variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for resources | `us-east-1` |
| `vpc_name` | Name prefix for VPC resources | `main` |
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` |
| `public_subnet_cidrs` | List of public subnet CIDRs | `["10.0.1.0/24", ...]` |
| `private_subnet_cidrs` | List of private subnet CIDRs | `["10.0.11.0/24", ...]` |
| `az_count` | Number of availability zones | `3` |
| `db_password` | RDS database password | *Required input* |
| `ami_id` | Custom AMI ID for EC2 | *Auto-discovered* |
| `domain_name` | Domain name for Route 53 | Environment-specific |
| `subdomain` | Subdomain for application | Environment-specific |

### Environment-Specific Configuration

Use `.tfvars` files for environment-specific values:

**dev.tfvars** (Development):
```hcl
aws_region           = "us-east-1"
vpc_name            = "dev-vpc"
vpc_cidr            = "10.0.0.0/16"
domain_name         = "your-domain-name"
subdomain           = "api"
az_count            = 3
db_instance_class   = "db.t3.micro"
ec2_instance_type   = "t2.micro"
min_size            = 1
max_size            = 3
desired_capacity    = 1
```

**demo.tfvars** (Production):
```hcl
aws_region           = "us-east-1"
vpc_name            = "demo-vpc"
vpc_cidr            = "10.1.0.0/16"
domain_name         = "your-domain-name"
subdomain           = "api"
az_count            = 3
db_instance_class   = "db.t3.small"
ec2_instance_type   = "t2.small"
min_size            = 2
max_size            = 6
desired_capacity    = 3
```

## Usage

### Development Environment
```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan infrastructure changes
AWS_PROFILE=dev terraform plan -var-file="dev.tfvars" \
  -var="db_password=YOURPASSWORD!"

# Apply infrastructure changes
AWS_PROFILE=dev terraform apply -var-file="dev.tfvars" \
  -var="db_password=YOURPASSWORD!"

# View outputs
terraform output

# Destroy infrastructure
AWS_PROFILE=dev terraform destroy -var-file="dev.tfvars" \
  -var="db_password=YOURPASSWORD!"
```

### Demo/Production Environment
```bash
# Plan
AWS_PROFILE=demo terraform plan -var-file="demo.tfvars" \
  -var="db_password=YOURPASSWORD!"

# Apply
AWS_PROFILE=demo terraform apply -var-file="demo.tfvars" \
  -var="db_password=YOURPASSWORD!"

# Destroy
AWS_PROFILE=demo terraform destroy -var-file="demo.tfvars" \
  -var="db_password=YOURPASSWORD!"
```

### Custom Configuration

Create your own `.tfvars` file:
```bash
terraform plan -var-file="custom.tfvars" \
  -var="db_password=YOURPASSWORD!"
```

## Outputs

The following outputs are available after deployment:

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC identifier |
| `vpc_cidr` | VPC CIDR block |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `internet_gateway_id` | Internet Gateway ID |
| `public_route_table_id` | Public route table ID |
| `private_route_table_id` | Private route table ID |
| `alb_dns_name` | Load balancer DNS name |
| `alb_arn` | Load balancer ARN |
| `rds_endpoint` | RDS database endpoint |
| `s3_bucket_name` | S3 bucket name |
| `application_url` | Full application URL |

View outputs:
```bash
# All outputs
terraform output

# Specific output
terraform output vpc_id

# Output as raw value (no quotes)
terraform output -raw alb_dns_name
```

## SSL Certificate Setup (DEMO Environment)

For the DEMO environment, import your SSL certificate to AWS Certificate Manager:

### Prerequisites
- Certificate file from Namecheap: `demo-domain-name.crt`
- Certificate chain/bundle: `demo-domain-name.ca-bundle`
- Private key: `demo-domain-name.key`

### Import Certificate
```bash
aws acm import-certificate \
  --certificate fileb://demo-domain-name.crt \
  --certificate-chain fileb://demo-domain-name.ca-bundle \
  --private-key fileb://demo-domain-name.key \
  --region us-east-1 \
  --profile demo
```

**Note:** The certificate ARN is automatically discovered by Terraform using the `aws_acm_certificate` data source.

## Verification & Testing

### 1. Verify AMI
```bash
# List custom AMIs
aws ec2 describe-images --owners self --profile dev --region us-east-1 \
  --query 'Images[*].[ImageId,Name,CreationDate]' --output table

# Get latest AMI ID
AMI_ID=$(aws ec2 describe-images --owners self --profile dev --region us-east-1 \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)

# Verify AMI sharing (if applicable)
aws ec2 describe-image-attribute --image-id $AMI_ID \
  --attribute launchPermission --profile dev --region us-east-1
```

### 2. Deploy Infrastructure
```bash
terraform init
AWS_PROFILE=dev terraform apply -var-file="dev.tfvars" \
  -var="db_password=YOURPASSWORD!"
```

### 3. Test Application
```bash
# Get application URL
APP_URL=$(terraform output -raw application_url)

# Test health endpoint
curl -i https://$APP_URL/healthz

# Expected: 200 OK
```

### 4. Verify Security

SSH into EC2 instance:
```bash
PUBLIC_IP=$(terraform output -raw ec2_public_ip)
ssh -i ~/.ssh/csye6225-aws ubuntu@$PUBLIC_IP
```

Check security requirements:
```bash
# Verify git is NOT installed
which git
# Expected: no output

# Verify application runs as webapp user
ps aux | grep java | grep webapp

# Check file ownership
sudo ls -la /opt/csye6225/webapp.jar
# Expected: owned by webapp:webapp

# Verify PostgreSQL is localhost only
sudo ss -tlnp | grep 5432
# Expected: listening on 127.0.0.1 only

# Check database connectivity
sudo -u postgres psql -d csye6225 -c "SELECT email FROM users;"

# Exit
exit
```

### 5. Verify Auto-Scaling
```bash
# Check Auto Scaling Group status
aws autoscaling describe-auto-scaling-groups \
  --profile dev --region us-east-1 \
  --query 'AutoScalingGroups[0].[DesiredCapacity,MinSize,MaxSize]'

# Check running instances
aws ec2 describe-instances \
  --profile dev --region us-east-1 \
  --filters "Name=tag:Name,Values=*webapp*" "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
  --output table
```

### 6. Verify Load Balancer
```bash
# Check target health
ALB_ARN=$(terraform output -raw alb_arn)
TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups \
  --load-balancer-arn $ALB_ARN --profile dev \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

aws elbv2 describe-target-health \
  --target-group-arn $TARGET_GROUP_ARN --profile dev
# Expected: All targets showing "healthy"
```

## Project Structure
```
tf-aws-infra/
├── main.tf                    # Main configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── dev.tfvars                # Dev environment config
├── demo.tfvars               # Demo environment config
├── modules/
│   ├── vpc/                  # VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/              # EC2 & ASG module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── database/             # RDS module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── storage/              # S3 module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/           # CloudWatch module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── .gitignore               # Git ignore file
└── README.md                # This file
```

## Terraform Best Practices

### State Management
- **Remote State:** Store state in S3 with DynamoDB locking
- **State Encryption:** Enable encryption at rest
- **Version Control:** Never commit `.tfstate` files

### Security
- **Secrets:** Never commit passwords or API keys
- **Variables:** Use `-var` flag or environment variables for secrets
- **IAM:** Follow least privilege principle
- **Encryption:** Enable for all data at rest and in transit

### Code Organization
- **Modules:** Reusable, well-documented modules
- **Variables:** Descriptive names and validation rules
- **Outputs:** Comprehensive output definitions
- **Comments:** Clear documentation in code

## Troubleshooting

### Common Issues

**Issue:** `Error acquiring the state lock`
```bash
# Solution: Force unlock (use carefully)
terraform force-unlock LOCK_ID
```

**Issue:** `Error creating VPC: VpcLimitExceeded`
```bash
# Solution: Delete unused VPCs or request limit increase
aws ec2 describe-vpcs --profile dev
```

**Issue:** AMI not found
```bash
# Solution: Verify AMI exists and is shared
aws ec2 describe-images --owners self --profile dev
```

**Issue:** Certificate not found
```bash
# Solution: Import certificate or verify domain name
aws acm list-certificates --profile demo --region us-east-1
```

### Debug Mode
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply -var-file="dev.tfvars"

# Disable debug logging
unset TF_LOG
```

## Clean Up

### Destroy Infrastructure
```bash
# Development
AWS_PROFILE=dev terraform destroy -var-file="dev.tfvars" \
  -var="db_password=YOURPASSWORD!"

# Demo
AWS_PROFILE=demo terraform destroy -var-file="demo.tfvars" \
  -var="db_password=YOURPASSWORD!"
```

**Warning:** This will permanently delete all resources. Make sure to:
- Backup any important data from RDS
- Save S3 bucket contents if needed
- Export CloudWatch logs if required

### Selective Destruction
```bash
# Destroy specific resource
terraform destroy -target=aws_instance.webapp -var-file="dev.tfvars"

# Destroy multiple resources
terraform destroy \
  -target=aws_instance.webapp \
  -target=aws_db_instance.postgres \
  -var-file="dev.tfvars"
```

## Cost Optimization

- **EC2 Instances:** Use t2/t3 instance types for dev, reserve instances for production
- **RDS:** Enable automated backups with retention, use Multi-AZ only for production
- **S3:** Implement lifecycle policies to move old data to cheaper storage classes
- **CloudWatch:** Set log retention periods, delete unused log groups
- **Load Balancer:** Consider using single ALB for multiple applications

## Contributing

This is a coursework project for CSYE 6225 - Network Structures and Cloud Computing at Northeastern University.

## License

This project is part of academic coursework and is not licensed for public use.

## Author

**Shreya Wanisha**
- GitHub: [@shreya2430](https://github.com/shreya2430) [@shreyawanisha](https://github.com/shreyawanisha)
- LinkedIn: [Shreya Wanisha](https://www.linkedin.com/in/shreya-wanisha/)

## Acknowledgments

- Northeastern University - CSYE 6225 Cloud Computing Course
- Terraform Documentation
- AWS Well-Architected Framework

---

**Infrastructure as Code for Cloud-Native Applications** 
