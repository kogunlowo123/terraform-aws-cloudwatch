locals {
  oam_sink_name = var.oam_sink_name != "" ? var.oam_sink_name : "${var.name}-monitoring-sink"

  common_tags = merge(var.tags, {
    Module    = "terraform-aws-cloudwatch"
    ManagedBy = "terraform"
  })
}
