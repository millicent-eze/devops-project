# ── TERRAFORM CONFIGURATION ──
# This file creates your entire AWS infrastructure with code
# Instead of clicking around in AWS console, you just run: terraform apply

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Store Terraform state in S3 so your team can share it
  backend "s3" {
    bucket = "devops-monitor-terraform-state"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

# ── AWS PROVIDER ──
provider "aws" {
  region = var.aws_region
}

# ── SECURITY GROUP ──
# Controls what traffic can reach your EC2 instance
resource "aws_security_group" "monitor_sg" {
  name        = "devops-monitor-sg"
  description = "Security group for DevOps Monitor app"

  # Allow SSH (port 22) — so you can connect to the server
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (port 80) — for the app
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow app port (3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Grafana (port 3001)
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Prometheus (port 9090)
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "devops-monitor-sg"
    Project = "devops-monitor"
  }
}

# ── EC2 INSTANCE ──
# This creates your virtual server on AWS
resource "aws_instance" "monitor_server" {
  ami                    = var.ami_id          # Ubuntu 22.04 LTS
  instance_type          = var.instance_type   # t2.micro (free tier)
  key_name               = var.key_name        # your SSH key
  vpc_security_group_ids = [aws_security_group.monitor_sg.id]

  # This script runs automatically when EC2 starts
  # It installs Docker and starts your app
  user_data = file("userdata.sh")

  tags = {
    Name    = "devops-monitor-server"
    Project = "devops-monitor"
  }
}

# ── S3 BUCKET ──
# Stores Terraform state and app assets

    

# ── CLOUDWATCH ALARM ──
# Sends alert when CPU is too high
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "devops-monitor-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "EC2 CPU usage is above 80%"

  dimensions = {
    InstanceId = aws_instance.monitor_server.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ── SNS TOPIC ──
# This is the notification channel CloudWatch uses to send alerts
resource "aws_sns_topic" "alerts" {
  name = "devops-monitor-alerts"
}
