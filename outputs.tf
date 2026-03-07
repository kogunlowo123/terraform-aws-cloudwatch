################################################################################
# Log Groups
################################################################################

output "log_group_arns" {
  description = "Map of log group names to ARNs"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

output "log_group_names" {
  description = "Map of log group keys to names"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

################################################################################
# Metric Alarms
################################################################################

output "metric_alarm_arns" {
  description = "Map of metric alarm names to ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}

output "metric_alarm_ids" {
  description = "Map of metric alarm names to IDs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.id }
}

################################################################################
# Composite Alarms
################################################################################

output "composite_alarm_arns" {
  description = "Map of composite alarm names to ARNs"
  value       = { for k, v in aws_cloudwatch_composite_alarm.this : k => v.arn }
}

################################################################################
# Dashboards
################################################################################

output "dashboard_arns" {
  description = "Map of dashboard names to ARNs"
  value       = { for k, v in aws_cloudwatch_dashboard.this : k => v.dashboard_arn }
}

################################################################################
# Anomaly Detection
################################################################################

output "anomaly_alarm_arns" {
  description = "Map of anomaly detection alarm names to ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.anomaly : k => v.arn }
}

################################################################################
# Synthetics Canaries
################################################################################

output "canary_arns" {
  description = "Map of canary names to ARNs"
  value       = { for k, v in aws_synthetics_canary.this : k => v.arn }
}

output "canary_engine_arns" {
  description = "Map of canary names to engine ARNs"
  value       = { for k, v in aws_synthetics_canary.this : k => v.engine_arn }
}

output "canary_source_location_arns" {
  description = "Map of canary names to source location ARNs"
  value       = { for k, v in aws_synthetics_canary.this : k => v.source_location_arn }
}

################################################################################
# Metric Streams
################################################################################

output "metric_stream_arns" {
  description = "Map of metric stream names to ARNs"
  value       = { for k, v in aws_cloudwatch_metric_stream.this : k => v.arn }
}

output "metric_stream_names" {
  description = "Map of metric stream keys to names"
  value       = { for k, v in aws_cloudwatch_metric_stream.this : k => v.name }
}

################################################################################
# Cross-Account Observability
################################################################################

output "oam_sink_arn" {
  description = "ARN of the OAM sink"
  value       = try(aws_oam_sink.this[0].arn, null)
}

output "oam_sink_id" {
  description = "ID of the OAM sink"
  value       = try(aws_oam_sink.this[0].id, null)
}

output "oam_link_arn" {
  description = "ARN of the OAM link"
  value       = try(aws_oam_link.this[0].arn, null)
}

output "oam_link_id" {
  description = "ID of the OAM link"
  value       = try(aws_oam_link.this[0].id, null)
}
