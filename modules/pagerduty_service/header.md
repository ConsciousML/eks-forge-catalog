# `pagerduty_service` Terraform Module Reference

The [`pagerduty_service` module](../pagerduty_service/) creates a PagerDuty service named `<environment>-eks-forge`, with an Events API v2 integration whose key Alertmanager sends events with.

The service uses an existing escalation policy (`Default` by default), looked up by name. The PagerDuty Free plan allows a single escalation policy.
