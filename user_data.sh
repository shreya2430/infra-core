#!/bin/bash

set -e
set -x

exec > >(tee /var/log/user-data.log) 2>&1

echo "======================================"
echo "Starting EC2 - Database Already Configured!"
echo "======================================"

# Everything is configured in AMI!
# Just start the application

sudo systemctl daemon-reload
sudo systemctl start webapp.service

sleep 5

sudo systemctl status webapp.service --no-pager || true

echo "======================================"
echo "EC2 Ready! Application started."
echo "======================================"