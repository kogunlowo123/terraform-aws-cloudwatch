################################################################################
# Log Groups
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = each.key
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id
  log_group_class   = each.value.log_group_class
  skip_destroy      = each.value.skip_destroy

  tags = merge(var.tags, each.value.tags)
}

################################################################################
# Metric Alarms
################################################################################

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.metric_alarms

  alarm_name          = each.key
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = length(each.value.metric_queries) > 0 ? null : each.value.statistic
  threshold           = each.value.threshold
  threshold_metric_id = each.value.threshold_metric_id

  alarm_description         = each.value.alarm_description
  alarm_actions             = each.value.alarm_actions
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions

  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data
  unit                = each.value.unit

  dimensions = length(each.value.dimensions) > 0 ? each.value.dimensions : null

  dynamic "metric_query" {
    for_each = each.value.metric_queries

    content {
      id          = metric_query.value.id
      expression  = metric_query.value.expression
      label       = metric_query.value.label
      return_data = metric_query.value.return_data

      dynamic "metric" {
        for_each = metric_query.value.metric != null ? [metric_query.value.metric] : []

        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          dimensions  = metric.value.dimensions
        }
      }
    }
  }

  tags = merge(var.tags, each.value.tags)
}

################################################################################
# Composite Alarms
################################################################################

resource "aws_cloudwatch_composite_alarm" "this" {
  for_each = var.composite_alarms

  alarm_name                = each.key
  alarm_rule                = each.value.alarm_rule
  alarm_description         = each.value.alarm_description
  alarm_actions             = each.value.alarm_actions
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions

  actions_suppressor                  = each.value.actions_suppressor
  actions_suppressor_extension_period = each.value.actions_suppressor_extension_period
  actions_suppressor_wait_period      = each.value.actions_suppressor_wait_period

  tags = merge(var.tags, each.value.tags)

  depends_on = [aws_cloudwatch_metric_alarm.this]
}

################################################################################
# Dashboards
################################################################################

resource "aws_cloudwatch_dashboard" "this" {
  for_each = var.dashboards

  dashboard_name = each.key
  dashboard_body = each.value.dashboard_body
}

################################################################################
# Anomaly Detection
################################################################################

resource "aws_cloudwatch_metric_alarm" "anomaly" {
  for_each = var.anomaly_detectors

  alarm_name          = "${each.key}-anomaly"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold_metric_id = "ad1"
  alarm_description   = "Anomaly detection for ${each.value.metric_name}"

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "${each.value.metric_name} anomaly band"
    return_data = true
  }

  metric_query {
    id          = "m1"
    return_data = true

    metric {
      metric_name = each.value.metric_name
      namespace   = each.value.namespace
      period      = 300
      stat        = each.value.stat
      dimensions  = each.value.dimensions
    }
  }

  tags = var.tags
}

################################################################################
# Synthetics Canaries
################################################################################

resource "aws_synthetics_canary" "this" {
  for_each = var.canaries

  name                 = each.key
  artifact_s3_location = each.value.artifact_s3_location
  execution_role_arn   = each.value.execution_role_arn
  handler              = each.value.handler
  runtime_version      = each.value.runtime_version

  s3_bucket  = each.value.s3_bucket
  s3_key     = each.value.s3_key
  s3_version = each.value.s3_version
  zip_file   = each.value.zip_file

  start_canary             = each.value.start_canary
  success_retention_period = each.value.success_retention_period
  failure_retention_period = each.value.failure_retention_period

  schedule {
    expression          = each.value.schedule_expression
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds    = each.value.timeout_in_seconds
    memory_in_mb          = each.value.memory_in_mb
    environment_variables = each.value.environment_variables
  }

  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []

    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = merge(var.tags, each.value.tags)
}

################################################################################
# Contributor Insights Rules
################################################################################

resource "aws_cloudwatch_contributor_insights_rule" "this" {
  for_each = var.contributor_insights_rules

  rule_name       = each.key
  rule_definition = each.value.rule_definition
  rule_state      = each.value.rule_state
}

################################################################################
# Metric Streams
################################################################################

resource "aws_cloudwatch_metric_stream" "this" {
  for_each = var.metric_streams

  name          = each.value.name_suffix != "" ? "${var.name}-${each.key}-${each.value.name_suffix}" : "${var.name}-${each.key}"
  role_arn      = each.value.role_arn
  firehose_arn  = each.value.firehose_arn
  output_format = each.value.output_format

  include_linked_accounts_metrics = each.value.include_linked_accounts_metrics

  dynamic "include_filter" {
    for_each = each.value.include_filters

    content {
      namespace    = include_filter.value.namespace
      metric_names = include_filter.value.metric_names
    }
  }

  dynamic "exclude_filter" {
    for_each = each.value.exclude_filters

    content {
      namespace    = exclude_filter.value.namespace
      metric_names = exclude_filter.value.metric_names
    }
  }

  dynamic "statistics_configuration" {
    for_each = each.value.statistics_configurations

    content {
      additional_statistics = statistics_configuration.value.additional_statistics

      dynamic "include_metric" {
        for_each = statistics_configuration.value.include_metrics

        content {
          metric_name = include_metric.value.metric_name
          namespace   = include_metric.value.namespace
        }
      }
    }
  }

  tags = merge(var.tags, each.value.tags)
}

################################################################################
# Cross-Account Observability - Monitoring Account (Sink)
################################################################################

resource "aws_oam_sink" "this" {
  count = var.create_monitoring_account_sink ? 1 : 0

  name = var.oam_sink_name != "" ? var.oam_sink_name : "${var.name}-monitoring-sink"

  tags = var.tags
}

resource "aws_oam_sink_policy" "this" {
  count = var.create_monitoring_account_sink ? 1 : 0

  sink_identifier = aws_oam_sink.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = length(var.oam_sink_allowed_source_accounts) > 0 ? { AWS = var.oam_sink_allowed_source_accounts } : "*"
        Action    = ["oam:CreateLink", "oam:UpdateLink"]
        Resource  = "*"
        Condition = length(var.oam_sink_allowed_source_organizations) > 0 ? {
          "ForAnyValue:StringEquals" = {
            "aws:PrincipalOrgID" = var.oam_sink_allowed_source_organizations
          }
          } : {
          "ForAllValues:StringEquals" = {
            "oam:ResourceTypes" = var.oam_sink_resource_types
          }
        }
      }
    ]
  })
}

################################################################################
# Cross-Account Observability - Source Account (Link)
################################################################################

resource "aws_oam_link" "this" {
  count = var.create_source_account_link ? 1 : 0

  label_template  = var.oam_link_label_template
  resource_types  = var.oam_link_resource_types
  sink_identifier = var.oam_link_sink_arn

  tags = var.tags
}
