<!-- BEGIN_TF_DOCS -->
# `pagerduty_service` Terraform Module Reference

The [`pagerduty_service` module](../pagerduty\_service/) creates a PagerDuty service named `<environment>-eks-forge`, with an Events API v2 integration whose key Alertmanager sends events with (see [From the Routing Key to a Page](/docs/monitoring/paging/how-paging-works/#from-the-routing-key-to-a-page)).

The service uses an existing escalation policy (`Default` by default), looked up by name. The PagerDuty Free plan allows a single escalation policy.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_pagerduty"></a> [pagerduty](#requirement\_pagerduty) | = 3.37.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_pagerduty"></a> [pagerduty](#provider\_pagerduty) | = 3.37.0 |

## Resources

| Name | Type |
|------|------|
| [pagerduty_service.this](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.37.0/docs/resources/service) | resource |
| [pagerduty_service_integration.this](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.37.0/docs/resources/service_integration) | resource |
| [pagerduty_escalation_policy.this](https://registry.terraform.io/providers/PagerDuty/pagerduty/3.37.0/docs/data-sources/escalation_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g. dev, staging, prod) used to prefix the service name so environments don't collide in the same account | `string` | n/a | yes |
| <a name="input_escalation_policy_name"></a> [escalation\_policy\_name](#input\_escalation\_policy\_name) | Name of the existing escalation policy assigned to the service | `string` | `"Default"` | no |
| <a name="input_service_region"></a> [service\_region](#input\_service\_region) | PagerDuty service region of the account, chosen at signup. Empty for US, eu for EU | `string` | `""` | no |
| <a name="input_token"></a> [token](#input\_token) | PagerDuty REST API key (General Access, not read-only). Used to create the service and its integration | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_integration_key"></a> [integration\_key](#output\_integration\_key) | Events API v2 integration key (routing key) that Alertmanager sends events with |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the PagerDuty service |
<!-- END_TF_DOCS -->