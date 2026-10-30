# Cloud DevOps Project - Deployment Notes

## Application
- Framework: Python Flask
- Containerization: Docker
- Container Registry: Amazon ECR
- Hosting: AWS EC2
- Infrastructure as Code: Terraform
- Remote Management: AWS Systems Manager

## Deployment Workflow

1. Developed a Flask application.
2. Created a Dockerfile.
3. Built the Docker image locally.
4. Created an ECR repository using Terraform.
5. Authenticated Docker with Amazon ECR.
6. Pushed the Docker image to ECR.
7. Configured EC2 IAM permissions to pull images.
8. Pulled the image onto EC2.
9. Started the Docker container on EC2.
10. Verified the application using curl.
11. Configured restricted inbound access using a security group.

## Application URL
http://13.203.223.175:5000

## Important Security Configuration
- EC2 access through AWS Systems Manager.
- IMDSv2 required.
- EBS volume encrypted.
- Application port 5000 restricted to a specific public IP.
