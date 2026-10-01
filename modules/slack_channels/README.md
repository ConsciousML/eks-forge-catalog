<!-- BEGIN_TF_DOCS -->
# `slack_channels` Terraform Module Reference

The [`slack_channels` module](../slack\_channels/) creates Slack channels from a list of base names, prefixing each with the environment name (e.g. `k8s-critical` becomes `dev-k8s-critical`).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_slack"></a> [slack](#requirement\_slack) | = 1.2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_slack"></a> [slack](#provider\_slack) | = 1.2.2 |

## Resources

| Name | Type |
|------|------|
| [slack_conversation.this](https://registry.terraform.io/providers/pablovarela/slack/1.2.2/docs/resources/conversation) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bot_token"></a> [bot\_token](#input\_bot\_token) | Slack bot token with channels:read, channels:manage, channels:join scopes. Used to create and manage channels | `string` | n/a | yes |
| <a name="input_channel_names"></a> [channel\_names](#input\_channel\_names) | Base channel names (no environment prefix, no leading '#') to create, one per Alertmanager receiver | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g. dev, staging, prod) used to prefix every channel name so environments don't collide in the same workspace | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_channel_names"></a> [channel\_names](#output\_channel\_names) | Environment-prefixed names of the channels that were created |
<!-- END_TF_DOCS -->