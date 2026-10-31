output "ubuntu_ami_id" {
  description = "Latest Ubuntu 24.04 AMI ID"
  value       = data.aws_ami.ubuntu.id
}

output "ubuntu_ami_name" {
  description = "Ubuntu AMI name"
  value       = data.aws_ami.ubuntu.name
}

output "ec2_instance_id" {
  value = aws_instance.app_server.id
}

output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.app_server.private_ip
}

output "ec2_instance_type" {
  value = aws_instance.app_server.instance_type
}

output "ec2_security_group_id" {
  value = aws_security_group.app_sg.id
}

output "ecr_repository_url" {
  description = "URL of the Docker image repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch email alerts"
  value       = aws_sns_topic.cloudwatch_alerts.arn
}
