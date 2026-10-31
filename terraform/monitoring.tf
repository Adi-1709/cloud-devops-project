data "aws_region" "current" {}

resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  dashboard_name = "${var.project_name}-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              aws_instance.app_server.id
            ]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.region
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "CWAgent",
              "mem_used_percent",
              "InstanceId",
              aws_instance.app_server.id
            ]
          ]
          period = 60
          stat   = "Average"
          region = data.aws_region.current.region
          title  = "EC2 Memory Usage (%)"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "CWAgent",
              "disk_used_percent",
              "path",
              "/",
              "InstanceId",
              aws_instance.app_server.id,
              "device",
              "nvme0n1p1",
              "fstype",
              "ext4"
            ]
          ]
          period = 60
          stat   = "Average"
          region = data.aws_region.current.region
          title  = "EC2 Disk Usage (%)"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  alarm_description   = "Triggers when EC2 CPU utilization exceeds 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]

  treat_missing_data = "notBreaching"
}

resource "aws_sns_topic" "cloudwatch_alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.cloudwatch_alerts.arn
  protocol  = "email"
  endpoint  = "adityarajeshjain@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.project_name}-high-memory"
  alarm_description   = "Triggers when EC2 memory usage exceeds 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  alarm_actions      = [aws_sns_topic.cloudwatch_alerts.arn]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_disk" {
  alarm_name          = "${var.project_name}-high-disk"
  alarm_description   = "Triggers when EC2 root disk usage exceeds 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    InstanceId = aws_instance.app_server.id
    path       = "/"
    device     = "nvme0n1p1"
    fstype     = "ext4"
  }

  alarm_actions      = [aws_sns_topic.cloudwatch_alerts.arn]
  treat_missing_data = "notBreaching"
}
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/cloud-devops-project/application"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/cloud-devops-project/system"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "auth_logs" {
  name              = "/cloud-devops-project/auth"
  retention_in_days = 14
}
