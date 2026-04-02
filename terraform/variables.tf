# ── TERRAFORM VARIABLES ──
# These are the inputs to your infrastructure
# Change values in terraform.tfvars (never commit that file!)

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # free tier eligible
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for eu-central-1"
  type        = string
  default     = "ami-0faab6bdbac9486fb"
}

variable "key_name" {
  description = "Name of your AWS key pair for SSH access"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true  # marks as secret — won't show in logs
}
