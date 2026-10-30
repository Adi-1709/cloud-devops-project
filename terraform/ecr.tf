resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-repository"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
