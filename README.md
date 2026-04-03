# 🚀 DevOps Monitoring Platform

A production-grade monitoring platform built with **Node.js, Docker, Prometheus, Grafana, Terraform and GitHub Actions** — with real-time **Slack alerts**.

---

## 📁 Project Structure

```
devops-monitor/
├── app/
│   ├── server.js               # Node.js app with metrics endpoint
│   ├── package.json
│   └── Dockerfile
├── terraform/
│   ├── main.tf                 # AWS infrastructure as code
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   └── userdata.sh             # EC2 startup script
├── prometheus/
│   ├── prometheus.yml          # Metrics collection config
│   └── alert_rules.yml         # Alert conditions
├── grafana/
│   └── datasource.yml          # Auto-connects to Prometheus
├── alertmanager/
│   └── alertmanager.yml        # Slack notification config
├── docker-compose.yml          # Runs all 5 containers
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline
├── .gitignore
└── README.md
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| **Node.js + Express** | The app being monitored |
| **Prometheus** | Collects metrics every 15s |
| **Grafana** | Visualizes metrics as dashboards |
| **Node Exporter** | Collects server CPU/RAM/disk metrics |
| **Alertmanager** | Sends Slack alerts when things go wrong |
| **Terraform** | Creates AWS infrastructure with code |
| **Docker + Compose** | Runs all services in containers |
| **GitHub Actions** | Automates testing and deployment |
| **AWS EC2** | Cloud server |
| **AWS S3** | Stores Terraform state |
| **AWS CloudWatch** | AWS-native monitoring |
| **Slack** | Receives alerts |

---

## 🚀 STEP BY STEP GUIDE

---

### PART 1 — Install required tools on your laptop

```bash
# Verify Node.js
node --version    # should be v18+

# Verify Docker
docker --version

# Verify Terraform
terraform --version

# Install Terraform (Windows):
# 1. Go to https://developer.hashicorp.com/terraform/install
# 2. Download Windows AMD64
# 3. Extract terraform.exe to C:\Windows\System32\
```

---

### PART 2 — Set up Slack

1. Go to **https://slack.com** → create a free workspace
2. Create a channel called **#devops-alerts**
3. Go to **https://api.slack.com/apps**
4. Click **"Create New App"** → **"From scratch"**
5. Name it `DevOps Monitor` → select your workspace
6. Click **"Incoming Webhooks"** → toggle **ON**
7. Click **"Add New Webhook to Workspace"**
8. Select **#devops-alerts** channel
9. Copy the webhook URL — looks like:
#
### PART 3 — Test locally first

```bash
# Clone the project
cd Desktop
cd devops-monitor

# Start all 5 containers
docker-compose up --build

# Visit these URLs:
# App:         http://localhost:3000
# Metrics:     http://localhost:3000/metrics
# Health:      http://localhost:3000/health
# Prometheus:  http://localhost:9090
# Grafana:     http://localhost:3001  (admin / devops123)
```

---

### PART 4 — Set up Grafana Dashboard

1. Open **http://localhost:3001**
2. Login: `admin` / `devops123`
3. Click **"+"** → **"Dashboard"** → **"Add new panel"**
4. Select **Prometheus** as data source
5. Add these queries one by one:

```
# HTTP Requests per second
rate(http_requests_total[1m])

# App response time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# CPU Usage %
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100)

# Memory Usage %
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
```

6. Save the dashboard as **"DevOps Monitor"**

---

### PART 5 — Set up Terraform on AWS

```bash
# Configure AWS CLI
aws configure
# Enter: Access Key ID, Secret Key, Region (eu-central-1), format (json)

# Go to terraform folder
cd terraform

# Initialize Terraform
terraform init

# Preview what will be created
terraform plan -var="key_name=your-key-name" -var="slack_webhook_url=your-webhook"

# Create the infrastructure
terraform apply -var="key_name=your-key-name" -var="slack_webhook_url=your-webhook"

# After it finishes, you'll see:
# ec2_public_ip = "54.xxx.xxx.xxx"
# app_url = "http://54.xxx.xxx.xxx:3000"
# grafana_url = "http://54.xxx.xxx.xxx:3001"
```

---

### PART 6 — Add GitHub Secrets

Go to your repo → **Settings → Secrets → Actions**

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your IAM access key |
| `AWS_SECRET_ACCESS_KEY` | Your IAM secret key |
| `AWS_REGION` | `eu-central-1` |
| `EC2_HOST` | Your EC2 public IP |
| `EC2_USER` | `ubuntu` |
| `EC2_SSH_KEY` | Contents of your .pem file |
| `EC2_KEY_NAME` | Name of your key pair in AWS |
| `SLACK_WEBHOOK_URL` | Your Slack webhook URL |

---

### PART 7 — Push to GitHub and deploy

```bash
git init
git add .
git commit -m "first commit: devops monitoring platform"
git remote add origin https://github.com/YOUR_USERNAME/devops-monitor.git
git push -u origin main
```

GitHub Actions will:
1. ✅ Test the app
2. ✅ Run Terraform to provision AWS
3. ✅ Deploy all containers to EC2
4. ✅ Send Slack notification

---

### PART 8 — Test your alerts

```bash
# Hit the error endpoint to trigger alerts
curl http://YOUR_EC2_IP:3000/error

# Hit the slow endpoint
curl http://YOUR_EC2_IP:3000/slow

# Check your #devops-alerts Slack channel!
```

---

## 📊 What you can monitor

| Metric | Where to see it |
|---|---|
| HTTP requests/sec | Grafana dashboard |
| Response time (p95) | Grafana dashboard |
| CPU usage | Grafana dashboard |
| Memory usage | Grafana dashboard |
| App up/down | Prometheus targets |
| CloudWatch CPU alarm | AWS Console |
| Slack alerts | #devops-alerts channel |

---

## 💼 How to describe this on your CV

> *"Built and deployed a production-grade DevOps monitoring platform on AWS EC2 using Terraform (IaC), Docker, Prometheus, and Grafana. Implemented automated CI/CD with GitHub Actions including infrastructure provisioning, containerized deployment, and real-time Slack alerting for incident response."*

---

## 🔧 Useful commands

```bash
# See all running containers
docker-compose ps

# See logs from specific container
docker-compose logs app
docker-compose logs prometheus
docker-compose logs grafana

# Restart a single container
docker-compose restart app

# Destroy everything (Terraform)
cd terraform && terraform destroy
```

---

*Built for learning · Monitored with Grafana · Deployed with Terraform & GitHub Actions*
