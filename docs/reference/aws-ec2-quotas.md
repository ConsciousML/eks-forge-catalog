{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS EC2 Quotas Bootstrap Reference

The [`ec2_quotas` stack](../../stacks/ec2_quotas/), deployed by the [`aws_service_quotas` pipeline](../../pipelines/bootstrap/aws_service_quotas/), requests an increase for the account's EC2 `L-1216C47A` (Running On-Demand Standard instances) and `L-34B43A08` (All Standard Spot Instance Requests) [Service Quotas](https://docs.aws.amazon.com/eks/latest/best-practices/known_limits_and_service_quotas.html#_other_aws_service_quotas).

With [`FEATURE_GPU_ENABLED`](../environment-variables.md#feature_gpu_enabled) set to `true`, it also requests `L-3819A6DF` (All G and VT Spot Instance Requests), which the [`gpu` feature](../../units/features/gpu/) launches its nodes under. Its AWS default is 0.

All quotas are account-wide: they cover every on-demand or spot vCPU consumer across every [environment](/docs/iac/#environments) on the account, not just this stack.

For setup steps, read the [AWS Service Quotas Bootstrap](/docs/quickstart/bootstrap/aws_service_quotas).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `ec2_ondemand_quota` | [`units/service_quota`](../../units/service_quota/) | [`service_quota`](/docs/reference/terraform_modules/service_quota/) |
| `ec2_spot_quota` | [`units/service_quota`](../../units/service_quota/) | [`service_quota`](/docs/reference/terraform_modules/service_quota/) |
| `ec2_gpu_spot_quota` | [`units/service_quota`](../../units/service_quota/) | [`service_quota`](/docs/reference/terraform_modules/service_quota/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `ondemand_desired_value` | Requested value for the `L-1216C47A` (On-Demand Standard) quota. | `number` | - | Yes |
| `spot_desired_value` | Requested value for the `L-34B43A08` (Spot Standard) quota. | `number` | - | Yes |
| `gpu_spot_desired_value` | Requested value for the `L-3819A6DF` (G and VT Spot) quota. `ec2_gpu_spot_quota` is generated only when it's above 0. | `number` | - | Yes |

The default values set in `terragrunt.stack.hcl` are a starting headroom above the AWS default, not a computed sum of any environment's vCPU usage.

## Sizing the Request

When the account already runs other EC2 workloads, the defaults don't account for their vCPU usage. Each value must cover the vCPUs already used on the account plus the EKS Forge headroom.

Set the values in the `locals` block of the [pipeline stack file](../../pipelines/bootstrap/aws_service_quotas/terragrunt.stack.hcl):
```hcl
locals {
  ondemand_desired_value = 32 # requested value for L-1216C47A
  spot_desired_value     = 32 # requested value for L-34B43A08
  gpu_spot_desired_value = get_env("FEATURE_GPU_ENABLED", "false") == "true" ? 16 : 0 # requested value for L-3819A6DF
}
```

## Outputs

Per unit (`ec2_ondemand_quota`, `ec2_spot_quota`, and `ec2_gpu_spot_quota`):

| Name | Description |
|------|-------------|
| `id` | The ID of the Service Quota request. |
| `status` | The status of the quota increase request (`PENDING`, `CASE_OPENED`, `APPROVED`, ...). |
