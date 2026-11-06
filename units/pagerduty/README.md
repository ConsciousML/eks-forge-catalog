# PagerDuty

Creates the PagerDuty service Alertmanager pages through, and stores its integration key in AWS Secrets Manager. Run once per environment.

Run via [`pipelines/bootstrap/pagerduty`](../../pipelines/bootstrap/pagerduty/) after manually creating the PagerDuty account and its REST API key.

## What's Inside

- **[service](service/)**: Creates the `<environment>-eks-forge` service and its Events API v2 integration, on the existing `Default` escalation policy.
- **[aws_secret](aws_secret/)**: Stores the integration key in the `<environment>-alertmanager-pagerduty` secret, under `routing_key`. The External Secrets Operator syncs it into the `alertmanager-pagerduty` Secret that Alertmanager mounts.

## Upstream Dependencies

- `PAGERDUTY_TOKEN` and `PAGERDUTY_SERVICE_REGION` (see [environment variables](../../docs/environment-variables.md)).
- An escalation policy named `Default` in the PagerDuty account. Every new account has one.
