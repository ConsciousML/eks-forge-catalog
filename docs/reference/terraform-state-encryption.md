{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Terraform State Encryption Bootstrap Reference

The [`terraform_state_encryption` stack](../../stacks/terraform_state_encryption/), deployed by the [`terraform_state_encryption` pipeline](../../pipelines/bootstrap/terraform_state_encryption/), creates the [AWS KMS](https://aws.amazon.com/kms/) [customer managed key](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#customer-mgn-key) that [`root.hcl`](/docs/reference/hcl_configuration/#roothcl) encrypts every state and plan with, and its [alias](https://docs.aws.amazon.com/kms/latest/developerguide/kms-alias.html).

For setup steps, read the [Terraform State Encryption Bootstrap](/docs/quickstart/bootstrap/terraform_state_encryption).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `state_kms_key` | [`units/state_kms_key`](../../units/state_kms_key/) | [`kms_key`](/docs/reference/terraform_modules/kms_key/) |

## Inputs

This stack takes no configurable inputs beyond `version`. The key's alias, `alias/<bootstrap-environment>-tofu-state`, is built in [`pipelines/root.hcl`](../../pipelines/root.hcl) from the `environment` of [`pipelines/bootstrap/environment.hcl`](../../pipelines/bootstrap/environment.hcl), read directly rather than passed in as a value.

## Outputs

| Name | Description |
|------|-------------|
| `key_arn` | ARN of the KMS key. |
| `alias_arn` | ARN of the KMS key alias. |

## Key Scope

The catalog has one key, in the region of [`pipelines/region.hcl`](../../pipelines/region.hcl). It encrypts the state of every catalog unit: the bootstrap pipelines, `dev`, any environment added with [Add a Dev Environment](/docs/iac/add-a-dev-environment/), and the plans of the [catalog CI](/docs/ci-cd/). Permission to decrypt with it reads all of these states. The live fork's `staging` and `prod` states use a key of their own.

The `state_kms_key` unit's own state isn't encrypted: the key doesn't exist yet when that state is first written. [`root.hcl`](/docs/reference/hcl_configuration/#roothcl) turns encryption off for every unit whose path contains `state_kms_key`.

## Deletion

The key has `prevent_destroy` set, so `terragrunt destroy` fails on this stack. Every encrypted state becomes unreadable once the key is deleted. To delete it after everything else, see [Remove EKS Forge](/docs/iac/remove-eks-forge/) and the [`kms_key` module](/docs/reference/terraform_modules/kms_key/#deletion) reference.
