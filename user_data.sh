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

# Restart application to pick up new environment
systemctl restart webapp.service