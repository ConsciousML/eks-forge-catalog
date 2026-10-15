<!-- BEGIN_TF_DOCS -->
# `kms_key` Terraform Module Reference

The [`kms_key` module](../kms\_key/) creates a symmetric [AWS KMS](https://aws.amazon.com/kms/) customer managed key with automatic rotation, and an alias pointing at it. The key uses the default key policy, so IAM policies control who can use it.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 6.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 6.55.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/6.55.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/6.55.0/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | Alias of the KMS key, starting with `alias/` | `string` | n/a | yes |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Number of days AWS waits before deleting the key once scheduled for deletion. Between 7 and 30 | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the KMS key | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | ARN of the KMS key alias |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | ARN of the KMS key |

## Deletion

The key has `prevent_destroy` set. Anything it encrypted becomes unreadable once the key is deleted. A key scheduled for deletion can be restored with `aws kms cancel-key-deletion` until `deletion_window_in_days` elapses.
<!-- END_TF_DOCS -->