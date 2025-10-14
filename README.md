# tf-aws-infra
testing
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
