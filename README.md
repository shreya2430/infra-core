# tf-aws-infra

## Configuration
- Variables
- All configurable variables are defined in variables.tf with default values:

- aws_region: AWS region for resources (default: us-east-1)
- vpc_name: Name prefix for VPC and related resources (default: main)
- vpc_cidr: CIDR block for VPC (default: 10.0.0.0/16)
- public_subnet_cidrs: List of CIDR blocks for public subnets
- private_subnet_cidrs: List of CIDR blocks for private subnets
- az_count: Number of availability zones to use (default: 3)

## Environment-Specific Configuration
- Use .tfvars files for environment-specific values:

- dev.tfvars: Development environment configuration
- demo.tfvars: Demo environment configuration

1.Initialize Terraform
```bash
  terraform init
```
2.Format code
```bash
  terraform fmt
```
3.Validate configuration
```bash
  terraform validate
```
4.Usage
## Dev
- Plan infrastructure changes
```bash
    AWS_PROFILE=dev terraform plan -var-file="dev.tfvars"
```
- Apply infrastructure changes
```bash
  AWS_PROFILE=dev terraform apply -var-file="dev.tfvars"
```

- Destroy infrastructure
```bash
  AWS_PROFILE=dev terraform destroy -var-file="dev.tfvars"
```

## Demo
- Plan infrastructure changes
```bash
  AWS_PROFILE=demo terraform plan -var-file="demo.tfvars"
```
- Apply infrastructure changes
```bash
  AWS_PROFILE=demo terraform apply -var-file="demo.tfvars"
```
- Destroy infrastructure
```bash
  AWS_PROFILE=demo terraform destroy -var-file="demo.tfvars"
```
## create a custom .tfvars file
```bash
  terraform plan -var-file="custom.tfvars"
```

# Outputs
- The following outputs are defined in outputs.tf:
* **vpc_id**: ID of the created VPC
* **vpc_cidr**: CIDR block of the VPC
* **public_subnet_ids**: List of public subnet IDs
* **private_subnet_ids**: List of private subnet IDs
* **internet_gateway_id**: ID of the Internet Gateway
* **public_route_table_id**: ID of the public route table
* **private_route_table_id**: ID of the private route table

- View outputs anytime with:
```bash
  terraform output
```

# Auto-format all files
```bash
  terraform fmt -recursive
```

# Assignment 5
## Part 1: Verify Packer AMI
```bash
# List your custom AMIs
aws ec2 describe-images --owners self --profile dev --region us-east-1 \
  --query 'Images[*].[ImageId,Name,CreationDate]' --output table

# Verify AMI is shared with DEMO account
AMI_ID=$(aws ec2 describe-images --owners self --profile dev --region us-east-1 \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
aws ec2 describe-image-attribute --image-id $AMI_ID \
  --attribute launchPermission --profile dev --region us-east-1
```
## Part 2: Deploy Terraform Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan
AWS_PROFILE=dev terraform plan -var-file="dev.tfvars" \
  -var="db_password=****" # replace **** with your DB password

# Apply
AWS_PROFILE=dev terraform apply -var-file="dev.tfvars" \
  -var="db_password=****" # replace **** with your DB password

# Get outputs
terraform output
```
## Part 3: Verify Application
```bash
PUBLIC_IP=$(terraform output -raw ec2_public_ip)

# Test your endpoints with the public IP address
```

## Part 4: Verify Security Requirements
```bash
# SSH into EC2
ssh -i ~/.ssh/csye6225-aws ubuntu@$PUBLIC_IP

# Check git NOT installed
which git

# Check application user
ps aux | grep java | grep webapp

# Check file ownership
sudo ls -la /opt/csye6225/webapp.jar

# Check database
sudo -u postgres psql -d csye6225 -c "SELECT email FROM users;"

# Check PostgreSQL only on localhost
sudo ss -tlnp | grep 5432

# Exit EC2
exit
```
## Part 5: Clean Up
```bash
# Destroy Terraform-managed infrastructure
AWS_PROFILE=dev terraform destroy -var-file="dev.tfvars" \
  -var="db_password=****" # replace **** with your DB password
```

## SSL Certificate for DEMO Environment

For the DEMO environment, we use an SSL certificate from Namecheap.

### Import Certificate to AWS ACM (DEMO Account)

After receiving the SSL certificate from Namecheap, import it to AWS Certificate Manager using the following command:
```bash
aws acm import-certificate \
  --certificate fileb://demo_cloud-webapp_me.crt \
  --certificate-chain fileb://demo_cloud-webapp_me.ca-bundle \
  --private-key fileb://demo_cloud-webapp_me.key \
  --region us-east-1 \
  --profile demo
```

**Files required:**
- `demo_cloud-webapp_me.crt` - Certificate file from Namecheap
- `demo_cloud-webapp_me.ca-bundle` - Certificate chain/bundle from Namecheap
- `demo_cloud-webapp_me.key` - Private key generated during CSR creation

**Note:** The certificate ARN will be automatically discovered by Terraform using the `aws_acm_certificate` data source.