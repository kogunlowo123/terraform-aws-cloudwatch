# terraform-aws-cloudwatch

Terraform module for comprehensive AWS CloudWatch observability including log groups, metric alarms, composite alarms, dashboards, anomaly detection, Synthetics canaries, Contributor Insights, metric streams, and cross-account observability.

## Architecture

```mermaid
flowchart TD
    A[CloudWatch] --> B[Log Groups]
    A --> C[Metric Alarms]
    A --> D[Composite Alarms]
    A --> E[Dashboards]
    A --> F[Anomaly Detection]
    A --> G[Synthetics Canaries]
    A --> H[Contributor Insights]
    A --> I[Metric Streams]
    A --> J[Cross-Account Observability]

    C --> C1[Standard Alarms]
    C --> C2[Math Expression Alarms]
    D --> C

    C1 --> K[SNS Notifications]
    C2 --> K
    D --> K

    F --> F1[Anomaly Band Detection]
    F1 --> C

    G --> G1[API Canary]
    G --> G2[Heartbeat Canary]
    G --> G3[Visual Canary]
    G1 --> L[S3 Artifacts]
    G2 --> L
    G3 --> L

    I --> M[Kinesis Firehose]
    M --> N[External Monitoring]

    J --> J1[OAM Sink]
    J --> J2[OAM Link]
    J1 --> O[Source Accounts]
    J2 --> P[Monitoring Account]

    B --> Q[Retention Policies]
    B --> R[KMS Encryption]

    style A fill:#FF4F8B,stroke:#CC3F6F,color:#FFFFFF
    style B fill:#FF9900,stroke:#CC7A00,color:#FFFFFF
    style C fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style D fill:#9B59B6,stroke:#8E44AD,color:#FFFFFF
    style E fill:#3498DB,stroke:#2980B9,color:#FFFFFF
    style F fill:#1ABC9C,stroke:#16A085,color:#FFFFFF
    style G fill:#2ECC71,stroke:#27AE60,color:#FFFFFF
    style H fill:#F39C12,stroke:#E67E22,color:#FFFFFF
    style I fill:#E91E63,stroke:#C2185B,color:#FFFFFF
    style J fill:#00BCD4,stroke:#0097A7,color:#FFFFFF
    style C1 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style C2 fill:#E74C3C,stroke:#C0392B,color:#FFFFFF
    style F1 fill:#1ABC9C,stroke:#16A085,color:#FFFFFF
    style G1 fill:#2ECC71,stroke:#27AE60,color:#FFFFFF
    style G2 fill:#2ECC71,stroke:#27AE60,color:#FFFFFF
    style G3 fill:#2ECC71,stroke:#27AE60,color:#FFFFFF
    style I fill:#E91E63,stroke:#C2185B,color:#FFFFFF
    style J1 fill:#00BCD4,stroke:#0097A7,color:#FFFFFF
    style J2 fill:#00BCD4,stroke:#0097A7,color:#FFFFFF
    style K fill:#F44336,stroke:#D32F2F,color:#FFFFFF
    style L fill:#FF9800,stroke:#F57C00,color:#FFFFFF
    style M fill:#795548,stroke:#5D4037,color:#FFFFFF
    style N fill:#607D8B,stroke:#455A64,color:#FFFFFF
    style O fill:#00BCD4,stroke:#0097A7,color:#FFFFFF
    style P fill:#00BCD4,stroke:#0097A7,color:#FFFFFF
    style Q fill:#FF9900,stroke:#CC7A00,color:#FFFFFF
    style R fill:#FF9900,stroke:#CC7A00,color:#FFFFFF
```

## Features

- **Log Groups** - Managed log groups with retention policies and KMS encryption
- **Metric Alarms** - Standard and math-expression based alarms with SNS actions
- **Composite Alarms** - Logical combinations of metric alarms
- **Dashboards** - JSON-defined CloudWatch dashboards
- **Anomaly Detection** - Automatic anomaly band detection on metrics
- **Synthetics Canaries** - Automated endpoint monitoring with configurable schedules
- **Contributor Insights** - Top-N analysis on log data
- **Metric Streams** - Real-time metric streaming to external destinations via Firehose
- **Cross-Account Observability** - OAM sinks and links for centralized monitoring

## Usage

```hcl
module "cloudwatch" {
  source = "path/to/terraform-aws-cloudwatch"

  name = "my-app"

  log_groups = {
    "/app/web" = {
      retention_in_days = 30
    }
  }

  metric_alarms = {
    high-cpu = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      threshold           = 80
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Examples

- [Basic](examples/basic/) - Log groups and metric alarms
- [Complete](examples/complete/) - Full observability stack with all features

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5.0 |
| aws       | >= 6.53.0 |

## License

MIT License - see [LICENSE](LICENSE) for details.
