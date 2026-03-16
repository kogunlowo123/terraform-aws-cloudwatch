variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "log_groups" {
  description = "Map of CloudWatch Log Groups to create"
  type = map(object({
    retention_in_days = optional(number, 30)
    kms_key_id        = optional(string)
    log_group_class   = optional(string, "STANDARD")
    skip_destroy      = optional(bool, false)
    tags              = optional(map(string), {})
  }))
  default = {}
}

variable "metric_alarms" {
  description = "Map of CloudWatch metric alarms to create"
  type = map(object({
    comparison_operator       = string
    evaluation_periods        = number
    metric_name               = optional(string)
    namespace                 = optional(string)
    period                    = optional(number, 300)
    statistic                 = optional(string, "Average")
    threshold                 = optional(number)
    threshold_metric_id       = optional(string)
    alarm_description         = optional(string, "")
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    datapoints_to_alarm       = optional(number)
    treat_missing_data        = optional(string, "missing")
    unit                      = optional(string)
    dimensions                = optional(map(string), {})
    metric_queries = optional(list(object({
      id          = string
      expression  = optional(string)
      label       = optional(string)
      return_data = optional(bool, true)
      metric = optional(object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string
        dimensions  = optional(map(string), {})
      }))
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "composite_alarms" {
  description = "Map of CloudWatch composite alarms to create"
  type = map(object({
    alarm_rule                          = string
    alarm_description                   = optional(string, "")
    alarm_actions                       = optional(list(string), [])
    ok_actions                          = optional(list(string), [])
    insufficient_data_actions           = optional(list(string), [])
    actions_suppressor                  = optional(string)
    actions_suppressor_extension_period = optional(number)
    actions_suppressor_wait_period      = optional(number)
    tags                                = optional(map(string), {})
  }))
  default = {}
}

variable "dashboards" {
  description = "Map of CloudWatch dashboards to create"
  type = map(object({
    dashboard_body = string
  }))
  default = {}
}

variable "anomaly_detectors" {
  description = "Map of CloudWatch anomaly detectors to create"
  type = map(object({
    metric_name = string
    namespace   = string
    stat        = string
    dimensions  = optional(map(string), {})
    excluded_time_ranges = optional(list(object({
      start_time = string
      end_time   = string
    })), [])
    metric_timezone = optional(string)
  }))
  default = {}
}

variable "canaries" {
  description = "Map of CloudWatch Synthetics canaries to create"
  type = map(object({
    artifact_s3_location     = string
    handler                  = string
    runtime_version          = string
    s3_bucket                = optional(string)
    s3_key                   = optional(string)
    s3_version               = optional(string)
    zip_file                 = optional(string)
    execution_role_arn       = string
    schedule_expression      = optional(string, "rate(5 minutes)")
    start_canary             = optional(bool, true)
    timeout_in_seconds       = optional(number, 60)
    memory_in_mb             = optional(number, 960)
    success_retention_period = optional(number, 31)
    failure_retention_period = optional(number, 31)
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }))
    environment_variables = optional(map(string), {})
    tags                  = optional(map(string), {})
  }))
  default = {}
}

variable "contributor_insights_rules" {
  description = "Map of CloudWatch Contributor Insights rules to create"
  type = map(object({
    rule_definition = string
    rule_state      = optional(string, "ENABLED")
  }))
  default = {}
}

variable "metric_streams" {
  description = "Map of CloudWatch Metric Streams to create"
  type = map(object({
    firehose_arn  = string
    role_arn      = string
    output_format = optional(string, "json")
    name_suffix   = optional(string, "")
    include_filters = optional(list(object({
      namespace    = string
      metric_names = optional(list(string), [])
    })), [])
    exclude_filters = optional(list(object({
      namespace    = string
      metric_names = optional(list(string), [])
    })), [])
    statistics_configurations = optional(list(object({
      additional_statistics = list(string)
      include_metrics = list(object({
        metric_name = string
        namespace   = string
      }))
    })), [])
    include_linked_accounts_metrics = optional(bool, false)
    tags                            = optional(map(string), {})
  }))
  default = {}
}

variable "create_monitoring_account_sink" {
  description = "Whether to create an OAM sink for the monitoring account"
  type        = bool
  default     = false
}

variable "oam_sink_name" {
  description = "Name of the OAM sink"
  type        = string
  default     = ""
}

variable "oam_sink_allowed_source_accounts" {
  description = "List of source account IDs allowed to link to the sink"
  type        = list(string)
  default     = []
}

variable "oam_sink_allowed_source_organizations" {
  description = "List of organization IDs allowed to link to the sink"
  type        = list(string)
  default     = []
}

variable "oam_sink_resource_types" {
  description = "Resource types to share via OAM sink"
  type        = list(string)
  default     = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup", "AWS::XRay::Trace"]
}

variable "create_source_account_link" {
  description = "Whether to create an OAM link for the source account"
  type        = bool
  default     = false
}

variable "oam_link_sink_arn" {
  description = "ARN of the monitoring account sink to link to"
  type        = string
  default     = ""
}

variable "oam_link_resource_types" {
  description = "Resource types to share from source account"
  type        = list(string)
  default     = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup", "AWS::XRay::Trace"]
}

variable "oam_link_label_template" {
  description = "Label template for the OAM link"
  type        = string
  default     = "$AccountName"
}
