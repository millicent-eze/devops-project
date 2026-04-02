#!/bin/bash
# ── EC2 STARTUP SCRIPT ──
# This runs automatically when your EC2 instance starts
# It installs everything needed to run the app

# Update packages
apt-get update -y

# Install Docker
apt-get install -y docker.io

# Install Docker Compose
apt-get install -y docker-compose

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install AWS CloudWatch Agent
# This sends EC2 metrics to CloudWatch
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Create app directory
mkdir -p /home/ubuntu/devops-monitor

echo "✅ EC2 setup complete! Docker and CloudWatch agent installed."
