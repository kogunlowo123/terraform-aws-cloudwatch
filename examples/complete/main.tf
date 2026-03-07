provider "aws" {
  region = "us-east-1"
}

module "cloudwatch" {
  source = "../../"

  name = "prod-observability"

  # Log Groups
  log_groups = {
    "/app/frontend" = {
      retention_in_days = 90
      log_group_class   = "STANDARD"
    }
    "/app/backend" = {
      retention_in_days = 90
    }
    "/app/workers" = {
      retention_in_days = 30
    }
  }

  # Metric Alarms
  metric_alarms = {
    high-cpu = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 85
      alarm_description   = "EC2 CPU utilization exceeds 85%"
      alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      ok_actions          = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      treat_missing_data  = "breaching"
      dimensions = {
        AutoScalingGroupName = "prod-asg"
      }
    }
    high-memory = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "MemoryUtilization"
      namespace           = "CWAgent"
      period              = 300
      statistic           = "Average"
      threshold           = 90
      alarm_description   = "Memory utilization exceeds 90%"
      alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alerts"]
    }
    api-errors = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      threshold           = 50
      alarm_description   = "API 5xx errors exceed threshold"
      alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:critical"]

      metric_queries = [
        {
          id          = "errors"
          return_data = true
          metric = {
            metric_name = "5XXError"
            namespace   = "AWS/ApiGateway"
            period      = 60
            stat        = "Sum"
            dimensions  = { ApiName = "prod-api" }
          }
        }
      ]
    }
    alb-latency = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      metric_name         = "TargetResponseTime"
      namespace           = "AWS/ApplicationELB"
      period              = 60
      statistic           = "p99"
      threshold           = 2
      alarm_description   = "ALB p99 latency exceeds 2 seconds"
      alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alerts"]
      dimensions = {
        LoadBalancer = "app/prod-alb/1234567890"
      }
    }
  }

  # Composite Alarms
  composite_alarms = {
    service-health = {
      alarm_rule        = "ALARM(\"high-cpu\") OR ALARM(\"high-memory\") OR ALARM(\"api-errors\")"
      alarm_description = "Composite alarm for overall service health"
      alarm_actions     = ["arn:aws:sns:us-east-1:123456789012:critical"]
    }
  }

  # Dashboards
  dashboards = {
    prod-overview = {
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
                ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "prod-asg", { stat = "Average" }]
              ]
              period = 300
              region = "us-east-1"
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
                ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/prod-alb/1234567890", { stat = "Sum" }]
              ]
              period = 60
              region = "us-east-1"
              title  = "ALB Request Count"
            }
          },
          {
            type   = "metric"
            x      = 0
            y      = 6
            width  = 24
            height = 6
            properties = {
              metrics = [
                ["AWS/ApiGateway", "5XXError", "ApiName", "prod-api", { stat = "Sum" }],
                ["AWS/ApiGateway", "4XXError", "ApiName", "prod-api", { stat = "Sum" }]
              ]
              period = 60
              region = "us-east-1"
              title  = "API Gateway Errors"
            }
          }
        ]
      })
    }
  }

  # Anomaly Detection
  anomaly_detectors = {
    request-count = {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      stat        = "Sum"
      dimensions = {
        LoadBalancer = "app/prod-alb/1234567890"
      }
    }
  }

  # Synthetics Canaries
  canaries = {
    api-health = {
      artifact_s3_location = "s3://prod-canary-artifacts/api-health"
      handler              = "apiCanaryBlueprint.handler"
      runtime_version      = "syn-nodejs-puppeteer-9.0"
      zip_file             = "canary-scripts/api-health.zip"
      execution_role_arn   = "arn:aws:iam::123456789012:role/canary-execution"
      schedule_expression  = "rate(5 minutes)"
      timeout_in_seconds   = 30
    }
  }

  # Contributor Insights Rules
  contributor_insights_rules = {
    top-talkers = {
      rule_state = "ENABLED"
      rule_definition = jsonencode({
        Schema = {
          Name    = "CloudWatchLogRule"
          Version = 1
        }
        LogGroupNames = ["/app/backend"]
        LogFormat     = "JSON"
        Contribution = {
          Keys  = ["$.sourceIp"]
          Filters = []
        }
        AggregateOn = "Count"
      })
    }
  }

  # Metric Streams
  metric_streams = {
    datadog-stream = {
      firehose_arn  = "arn:aws:firehose:us-east-1:123456789012:deliverystream/datadog-metrics"
      role_arn      = "arn:aws:iam::123456789012:role/metric-stream"
      output_format = "opentelemetry1.0"
      include_filters = [
        { namespace = "AWS/EC2" },
        { namespace = "AWS/ApplicationELB" },
        { namespace = "AWS/ApiGateway" },
        { namespace = "AWS/RDS" },
      ]
    }
  }

  # Cross-Account Observability (Monitoring account)
  create_monitoring_account_sink       = true
  oam_sink_name                        = "central-monitoring"
  oam_sink_allowed_source_accounts     = ["111111111111", "222222222222"]
  oam_sink_resource_types              = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup", "AWS::XRay::Trace"]

  tags = {
    Environment = "production"
    Project     = "observability"
    CostCenter  = "platform"
  }
}

output "log_group_arns" {
  value = module.cloudwatch.log_group_arns
}

output "alarm_arns" {
  value = module.cloudwatch.metric_alarm_arns
}

output "dashboard_arns" {
  value = module.cloudwatch.dashboard_arns
}

output "oam_sink_arn" {
  value = module.cloudwatch.oam_sink_arn
}
