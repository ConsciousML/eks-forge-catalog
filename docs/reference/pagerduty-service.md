{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# PagerDuty Service Bootstrap Reference

The [`pagerduty_service` stack](../../stacks/pagerduty_service/), deployed by the [`pagerduty/services` pipeline](../../pipelines/bootstrap/pagerduty/services/), creates that environment's PagerDuty service, named `<environment>-eks-forge`, on the existing `Default` escalation policy. It stores the service's Events API v2 integration key in the `<environment>-alertmanager-pagerduty` AWS Secrets Manager secret, under `routing_key`, for Alertmanager to page through. Run once per environment.

For setup steps, read the [PagerDuty Bootstrap](/docs/quickstart/bootstrap/pagerduty).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `pagerduty_service` | [`units/pagerduty/service`](../../units/pagerduty/service/) | [`pagerduty_service`](/docs/reference/terraform_modules/pagerduty_service/) |
| `pagerduty_aws_secret` | [`units/pagerduty/aws_secret`](../../units/pagerduty/aws_secret/) | [`aws_secretsmanager_secret`](/docs/reference/terraform_modules/aws_secretsmanager_secret/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `token` | PagerDuty REST API key (General Access, not read-only), from [`PAGERDUTY_TOKEN`](/docs/reference/environment_variable/#pagerduty_token-and-pagerduty_service_region). | `string` | - | Yes |
| `service_region` | Service region of the PagerDuty account, chosen at signup. Empty for US, `eu` for EU. | `string` | `""` | No |
| `environment` | Environment name (e.g. `dev`, `staging`, `prod`) used to prefix the service and secret names so environments don't collide in the same account. | `string` | - | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `service_name` | Name of the PagerDuty service. |
| `integration_key` | Events API v2 integration key (routing key) that Alertmanager sends events with. Sensitive. |
| `secret_arn` | ARN of the Secrets Manager secret holding the integration key. |
| `secret_name` | Name of the Secrets Manager secret holding the integration key. |
