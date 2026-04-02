# ── TERRAFORM OUTPUTS ──
# These print useful information after terraform apply runs

output "ec2_public_ip" {
  description = "Public IP of your EC2 instance"
  value       = aws_instance.monitor_server.public_ip
}

output "app_url" {
  description = "URL to access your app"
  value       = "http://${aws_instance.monitor_server.public_ip}:3000"
}

output "grafana_url" {
  description = "URL to access Grafana dashboard"
  value       = "http://${aws_instance.monitor_server.public_ip}:3001"
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${aws_instance.monitor_server.public_ip}:9090"
}

output "metrics_url" {
  description = "URL to see raw metrics"
  value       = "http://${aws_instance.monitor_server.public_ip}:3000/metrics"
}
