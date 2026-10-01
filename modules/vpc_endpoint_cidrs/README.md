<!-- BEGIN_TF_DOCS -->
# `vpc_endpoint_cidrs` Terraform Module Reference

The [`vpc_endpoint_cidrs` module](../vpc\_endpoint\_cidrs/) computes the pinned ENI IP of each interface VPC endpoint from a private subnet CIDR and a per-service host offset, and creates no resources. It is the single source of the `cidrhost()` math read by [`units/vpc/endpoints`](../../units/vpc/endpoints/), which pairs each IP with its subnet ID, and by [`units/eks/addons/argocd/app_of_apps`](../../units/eks/addons/argocd/app\_of\_apps/), which passes the plain IP list as the `vpcEndpointCidrs` app parameter of a `CiliumNetworkPolicy`.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_param_key_map"></a> [app\_param\_key\_map](#input\_app\_param\_key\_map) | Subset of endpoint\_host\_offsets keys, re-keyed to the appParams key each consumer expects | `map(string)` | n/a | yes |
| <a name="input_endpoint_host_offsets"></a> [endpoint\_host\_offsets](#input\_endpoint\_host\_offsets) | Host offset within each private subnet CIDR, per interface endpoint service | `map(number)` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Private subnet IDs, in AZ order | `list(string)` | n/a | yes |
| <a name="input_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#input\_private\_subnets\_cidr\_blocks) | Private subnet CIDR blocks, in the same AZ order as private\_subnets | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_ips"></a> [endpoint\_ips](#output\_endpoint\_ips) | Pinned ENI IP per subnet, per interface endpoint service |
| <a name="output_vpc_endpoint_cidrs"></a> [vpc\_endpoint\_cidrs](#output\_vpc\_endpoint\_cidrs) | Pinned ENI IPs, re-keyed through app\_param\_key\_map for CiliumNetworkPolicy consumers |
<!-- END_TF_DOCS -->