#!/bin/bash
set -e

# Log everything to a file for debugging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting user data script..."

# Get AWS region from instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region)

echo "AWS Region: $REGION"

# Retrieve database password from Secrets Manager
echo "Retrieving database password from Secrets Manager..."
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id ${vpc_name}-db-password \
  --region $REGION \
  --query SecretString \
  --output text)

if [ -z "$DB_PASSWORD" ]; then
  echo "ERROR: Failed to retrieve database password from Secrets Manager"
  exit 1
fi

echo "Database password retrieved successfully"

# Retrieve SendGrid API key from Secrets Manager
echo "Retrieving SendGrid API key from Secrets Manager..."
SENDGRID_API_KEY=$(aws secretsmanager get-secret-value \
  --secret-id ${vpc_name}-sendgrid-api-key \
  --region $REGION \
  --query SecretString \
  --output text)

if [ -z "$SENDGRID_API_KEY" ]; then
  echo "ERROR: Failed to retrieve SendGrid API key from Secrets Manager"
  exit 1
fi

echo "SendGrid API key retrieved successfully"

# Create environment file for application
echo "Creating application environment file..."
cat > /opt/csye6225/webapp.env << EOF
DB_HOST=${db_host}
DB_PORT=5432
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=$DB_PASSWORD
S3_BUCKET_NAME=${s3_bucket_name}
AWS_REGION=${aws_region}
SENDGRID_API_KEY=$SENDGRID_API_KEY
SNS_TOPIC_ARN=${sns_topic_arn}
EOF

# Set permissions
chown csye6225:csye6225 /opt/csye6225/webapp.env
chmod 400 /opt/csye6225/webapp.env

echo "Environment file created successfully"

# Start CloudWatch Agent
echo "Starting CloudWatch Agent..."
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json

# Verify CloudWatch Agent is running
sleep 5
systemctl status amazon-cloudwatch-agent || true

# Enable and start application
echo "Enabling and starting application service..."
systemctl enable webapp.service
systemctl start webapp.service

# Wait a moment and check if service started
sleep 3
systemctl status webapp.service

echo "User data script completed successfully"