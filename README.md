# AWS Cloud DevOps CI/CD Project

An end-to-end DevOps project that automates the build, containerization, and deployment of a Python Flask application on AWS EC2 using GitHub Actions, Docker, Terraform, Amazon ECR, and AWS Systems Manager.

## Project Overview

This project implements an automated CI/CD pipeline. Whenever code is pushed to the `main` branch, GitHub Actions automatically builds a Docker image, pushes it to Amazon ECR, and deploys it to an EC2 instance.

GitHub authenticates with AWS through OpenID Connect (OIDC), eliminating the need to store long-term AWS access keys.

## Architecture

```text
Developer
   |
   | Git Push
   v
GitHub Repository
   |
   v
GitHub Actions
   |
   v
AWS IAM (OIDC)
   |
   v
Docker Build
   |
   v
Amazon ECR
   |
   v
AWS Systems Manager
   |
   v
Amazon EC2
   |
   v
Docker Container
   |
   v
Python Flask Application
   |
   v
HTTP Health Check
```

## Technology Stack

| Technology          | Purpose                        |
| ------------------- | ------------------------------ |
| AWS EC2             | Application hosting            |
| Amazon ECR          | Docker image registry          |
| AWS IAM             | Identity and access management |
| AWS OIDC            | Secure GitHub authentication   |
| AWS Systems Manager | Remote deployment              |
| Terraform           | Infrastructure as Code         |
| GitHub Actions      | CI/CD automation               |
| Docker              | Containerization               |
| Python Flask        | Backend application            |
| Ubuntu 24.04        | EC2 operating system           |

## Repository Structure

```text
cloud-devops-project/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── application/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── documentation/
│   └── deployment-notes.md
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── data.tf
│   ├── ec2.tf
│   ├── ecr.tf
│   ├── iam.tf
│   ├── security.tf
│   └── outputs.tf
├── .gitignore
└── README.md
```

## AWS Infrastructure

Terraform manages the following infrastructure:

* Ubuntu 24.04 EC2 instance.
* Amazon ECR repository with image scanning.
* IAM roles and EC2 instance profile.
* GitHub Actions IAM role with OIDC trust.
* IAM permissions for ECR publishing and SSM deployment.
* EC2 security group.
* Encrypted 10 GB gp3 EBS root volume.
* IMDSv2 enforcement.

**AWS Region:** `ap-south-1` (Mumbai)

**EC2 Instance Type:** `t3.micro`

## CI/CD Pipeline

The pipeline is configured in `.github/workflows/deploy.yml`.

### 1. Trigger

Runs automatically on pushes to `main` or through manual workflow dispatch.

### 2. AWS Authentication

Uses GitHub OIDC to assume an IAM role without storing long-term AWS access keys.

### 3. Docker Build

Builds the Flask application image from the `application/` directory.

### 4. Amazon ECR

Tags the image using the GitHub commit SHA and pushes it to ECR.

### 5. EC2 Deployment

Uses AWS Systems Manager Run Command to:

* Authenticate Docker with ECR.
* Pull the new image.
* Stop and remove the previous container.
* Start the updated container.
* Configure automatic container restart.

### 6. Health Check

Checks the Flask application on `127.0.0.1:5000`, retrying up to 15 times.

The workflow reports success only after the application responds successfully.

## Local Setup

### Prerequisites

* Git
* Docker
* Python 3.12+ (optional for running without Docker)

### Clone the repository

```bash
git clone https://github.com/Adi-1709/cloud-devops-project.git
cd cloud-devops-project
```

### Build the Docker image

```bash
docker build -t cloud-devops-app ./application
```

### Run the container

```bash
docker run -d -p 5000:5000 --name cloud-devops-container cloud-devops-app
```

### Verify

Open `http://localhost:5000` or run:

```bash
curl http://localhost:5000
```

## Terraform Commands

Run these commands from the `terraform/` directory.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

To remove infrastructure when it is no longer required:

```bash
terraform destroy
```

Review the Terraform plan carefully before applying or destroying resources.

## Security Practices

* GitHub OIDC authentication instead of long-term AWS access keys.
* IAM roles with scoped permissions.
* EC2 management through AWS Systems Manager.
* IMDSv2 required.
* Encrypted EBS root volume.
* ECR image scanning enabled.
* Security group rules restrict application access.

## Deployment Verification

After a successful GitHub Actions run:

* Check the workflow in the GitHub Actions tab.
* Verify the image in Amazon ECR.
* Verify the Docker container on EC2.
* Confirm the Flask application responds successfully.


## Monitoring and Observability

The project uses Amazon CloudWatch to monitor EC2 infrastructure,
collect application and operating system logs, and generate alerts.

### CloudWatch Dashboard

Dashboard: `cloud-devops-project-monitoring`

Metrics monitored:
- EC2 CPU utilization.
- EC2 memory utilization using CloudWatch Agent.
- EC2 root disk utilization using CloudWatch Agent.

### CloudWatch Alarms

Three alarms are configured with an 80% threshold:

| Alarm | Metric | Evaluation |
|---|---|---|
| High CPU | CPUUtilization | 2 × 300 seconds |
| High Memory | mem_used_percent | 2 × 60 seconds |
| High Disk | disk_used_percent | 2 × 60 seconds |

All alarms publish notifications to an Amazon SNS topic.

### Email Notifications

- SNS topic: `cloud-devops-project-alerts`
- Email subscription configured and confirmed.
- Notifications are triggered by configured CloudWatch alarms.

### Centralized Logging

CloudWatch Agent collects application and operating system logs.

| Log Group | Source | Retention |
|---|---|---|
| `/cloud-devops-project/application` | Docker / Flask application | 14 days |
| `/cloud-devops-project/system` | Ubuntu syslog | 14 days |
| `/cloud-devops-project/auth` | Ubuntu authentication logs | 14 days |

The logging pipeline was verified by generating an HTTP request and
confirming its HTTP 200 access log in CloudWatch Logs.

System and authentication log ingestion were also verified.

### IAM Permissions

The EC2 instance role includes:
- AmazonEC2ContainerRegistryReadOnly
- AmazonSSMManagedInstanceCore
- CloudWatchAgentServerPolicy

Terraform provisions the monitoring dashboard, alarms, SNS resources,
log groups, IAM permissions, and log retention settings.

The CloudWatch Agent installation and configuration on EC2 were
performed separately through AWS Systems Manager.

## Future Improvements

* Automated application tests.
* Blue-green or rolling deployments.
* Application Load Balancer and HTTPS.
* Amazon CloudWatch monitoring and alarms.
* Docker image vulnerability scanning.
* Automatic rollback after deployment failures.
* Separate staging and production environments.

## Author

**Aditya Jain**

GitHub: [Adi-1709](https://github.com/Adi-1709)

Project Repository: [cloud-devops-project](https://github.com/Adi-1709/cloud-devops-project)
