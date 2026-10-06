{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

This guide shows you how to create an [interface VPC endpoint](https://docs.aws.amazon.com/vpc/latest/privatelink/vpce-interface.html) for an AWS service from your [forked catalog](/docs/quickstart/installation/#fork-the-eks-forge-catalog), validate it in [`dev`](/docs/iac/#dev), and merge it.

You need it when an app calls an AWS API that has no endpoint yet. Without one, the app's network policy has to allow egress to `world` on port 443, which opens the whole internet. The endpoint gets a fixed IP in each private subnet, so the policy can allow only those IPs instead (see [Reaching AWS APIs](/docs/security/how-network-policies-work/#reaching-aws-apis)).

To write that rule once the endpoint exists, see [Allow an AWS API](/docs/security/write-network-policies/#allow-an-aws-api).

If you don't have a branch in your forked catalog yet, create one:
```bash
git checkout -b <branch>
```

## Find the Service Name

Export your service, replacing `<service>` (e.g. `kms`):
```bash
export SERVICE=<service>
```

Then print its endpoint names:
```bash
aws ec2 describe-vpc-endpoint-services --query "ServiceNames[?contains(@, '$SERVICE')]" --output text
```

For example, for KMS:
```text
com.amazonaws.us-east-1.kms	com.amazonaws.us-east-1.kms-fips
```

Your service's key is the end of the name you need, after the region:

| Name | Key |
|------|-----|
| `com.amazonaws.us-east-1.kms` | `kms` |
| `com.amazonaws.us-east-1.ecr.api` | `ecr.api` |
| `com.amazonaws.route53` | `route53` |

Some names have no region, like Route 53's. Note it for the next section.

S3 and DynamoDB use a [gateway endpoint](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html) instead, which has no IP to fix. The catalog already creates the S3 one, and a policy reaching either still allows `world` (see [Reaching AWS APIs](/docs/security/how-network-policies-work/#reaching-aws-apis)).

:::warning
Don't add `s3` in the next section. The unit keeps its gateway endpoint and ignores the entry.
:::

## Add the Service

Add your key to `endpoint_host_offsets` in [`pipelines/network.hcl`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/blob/main/pipelines/network.hcl), with the offset that follows the highest one. Quote a key that contains a dot, like `"ecr.api"`. For example, for KMS:
```hcl
endpoint_host_offsets = {
  ...
  acm = 21
  kms = 22
}
```

If your service's name has no region, also add its key to `global_services` in [`units/vpc/endpoints/terragrunt.hcl`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/blob/main/units/vpc/endpoints/terragrunt.hcl). Otherwise, the unit looks for the endpoint under a name with a region, and the apply fails:
```hcl
global_services = ["route53", "iam", "<key>"]
```

## Validate in Dev

Follow [Validate in Dev](/docs/iac/add-a-unit/#validate-in-dev). The endpoint takes the address at your offset in each private subnet. If the apply fails because one is already in use, pick a higher offset and apply again.

To check that the endpoint exists, print its state, replacing `<service-name>` with the name from [Find the Service Name](#find-the-service-name):
```bash
aws ec2 describe-vpc-endpoints --filters Name=service-name,Values=<service-name> --query 'VpcEndpoints[].State' --output text
```

It prints `available` once the endpoint is ready.

## Open a Pull Request and Merge

Follow [Open a Pull Request](/docs/iac/add-a-unit/#open-a-pull-request) and [Merge](/docs/iac/add-a-unit/#merge).

## Ship the Endpoint to Staging and Prod

Follow [Release a Change to Production](/docs/deployment/release-a-change-to-production/). In its [Release an IaC Change](/docs/iac/release-an-iac-change/) step, your key goes into the `endpoint_host_offsets` of your live fork's `live/network.hcl`, as in [Update the Shared Configuration](/docs/iac/release-an-iac-change/#update-the-shared-configuration).

If you came from [Write Network Policies](/docs/security/write-network-policies/), return to [Allow an AWS API](/docs/security/write-network-policies/#allow-an-aws-api).
