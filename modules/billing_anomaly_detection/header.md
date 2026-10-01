# `billing_anomaly_detection` Terraform Module Reference

The [`billing_anomaly_detection` module](../billing_anomaly_detection/) creates an [AWS Cost Anomaly Detection](https://aws.amazon.com/aws-cost-management/aws-cost-anomaly-detection/) monitor and subscription that emails a notification when a detected spend anomaly's cost impact reaches or exceeds a USD threshold. Anomalies are measured against the account's own spend history, not a fixed budget.
