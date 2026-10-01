# `service_quota` Terraform Module Reference

The [`service_quota` module](../service_quota/) requests an increase for a single [AWS Service Quota](https://docs.aws.amazon.com/servicequotas/latest/userguide/intro.html). `service_code` and `quota_code` identify the quota (e.g. `ec2` / `L-1216C47A` for Running On-Demand Standard instances) and `desired_value` is the requested value.
