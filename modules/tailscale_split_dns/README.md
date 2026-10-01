<!-- BEGIN_TF_DOCS -->
# `tailscale_split_dns` Terraform Module Reference

The [`tailscale_split_dns` module](../tailscale\_split\_dns/) configures Tailscale [split DNS](https://tailscale.com/kb/1054/dns#restricted-nameservers) to forward queries for a private domain to the VPC DNS resolver, so tailnet devices resolve private Route 53 records.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | = 0.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | = 0.28.0 |

## Resources

| Name | Type |
|------|------|
| [tailscale_dns_split_nameservers.this](https://registry.terraform.io/providers/tailscale/tailscale/0.28.0/docs/resources/dns_split_nameservers) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | The domain suffix whose DNS queries will be forwarded to the nameservers | `string` | n/a | yes |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | List of nameserver IPs to forward DNS queries to | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->