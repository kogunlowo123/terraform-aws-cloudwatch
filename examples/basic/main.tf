provider "aws" {
  region = "us-east-1"
}

module "cloudwatch" {
  source = "../../"

  name = "my-app"

  log_groups = {
    "/app/web" = {
      retention_in_days = 14
    }
    "/app/api" = {
      retention_in_days = 30
    }
  }

  metric_alarms = {
    high-cpu = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      alarm_description   = "CPU utilization exceeds 80%"
      dimensions = {
        InstanceId = "i-0123456789abcdef0"
      }
    }
  }

  tags = {
    Environment = "dev"
  }
}

output "log_group_arns" {
  value = module.cloudwatch.log_group_arns
}

output "alarm_arns" {
  value = module.cloudwatch.metric_alarm_arns
}
