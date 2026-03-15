terraform {
  required_version = ">= 1.7.0"
}

module "test" {
  source = "../"

  name = "test-monitoring"

  log_groups = {
    "app-logs" = {
      retention_in_days = 30
      log_group_class   = "STANDARD"
      skip_destroy      = false
    }
    "error-logs" = {
      retention_in_days = 90
      log_group_class   = "STANDARD"
    }
  }

  metric_alarms = {
    "high-cpu" = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      alarm_description   = "CPU utilization exceeds 80%"
      treat_missing_data  = "missing"
      dimensions = {
        AutoScalingGroupName = "test-asg"
      }
    }
  }

  dashboards = {
    "main-dashboard" = {
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
                ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "test-asg"]
              ]
              period = 300
              stat   = "Average"
              region = "us-east-1"
              title  = "CPU Utilization"
            }
          }
        ]
      })
    }
  }

  tags = {
    Test = "true"
  }
}
