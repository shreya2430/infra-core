#!/bin/bash
set -e

# Create environment file for application
cat > /opt/csye6225/webapp.env << EOF
DB_HOST=${db_host}
DB_PORT=5432
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
S3_BUCKET_NAME=${s3_bucket_name}
AWS_REGION=${aws_region}
EOF

# Set permissions
chown csye6225:csye6225 /opt/csye6225/webapp.env
chmod 400 /opt/csye6225/webapp.env

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

# Restart application to pick up new environment
systemctl restart webapp.service

echo "Userdata script completed successfully"