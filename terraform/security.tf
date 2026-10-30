data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for cloud devops EC2"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "flask_test" {
  security_group_id = aws_security_group.app_sg.id

  cidr_ipv4   = "152.59.190.206/32"
  from_port   = 5000
  to_port     = 5000
  ip_protocol = "tcp"

  description = "Temporary Flask application access"
}
