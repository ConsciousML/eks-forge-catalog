# PagerDuty

Creates the PagerDuty service Alertmanager pages through, stores its integration key in AWS Secrets Manager, and registers the account's service region as a GitHub Actions secret.

Run via [`pipelines/bootstrap/pagerduty`](../../pipelines/bootstrap/pagerduty/) after manually creating the PagerDuty account and its REST API key.

## What's Inside

- **[service](service/)**: Creates the `<environment>-eks-forge` service and its Events API v2 integration, on the existing `Default` escalation policy. Run once per environment.
- **[aws_secret](aws_secret/)**: Stores the integration key in the `<environment>-alertmanager-pagerduty` secret, under `routing_key`. The External Secrets Operator syncs it into the `alertmanager-pagerduty` Secret that Alertmanager mounts. Run once per environment.
- **[github_secrets](github_secrets/)**: Stores `PAGERDUTY_SERVICE_REGION`, sourced from `.env`, as a GitHub Actions secret so CI-driven environments page the right Events API endpoint. An empty (US) region is stored as `us`, since a GitHub secret can't be empty. Environment-independent, run once.

## Upstream Dependencies

- `PAGERDUTY_TOKEN` and `PAGERDUTY_SERVICE_REGION` (see [environment variables](../../docs/environment-variables.md)).
- An escalation policy named `Default` in the PagerDuty account. Every new account has one.
