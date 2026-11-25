# VPC Endpoints

Wraps the [terraform-aws-modules/vpc//modules/vpc-endpoints](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest/submodules/vpc-endpoints) submodule to provision VPC endpoints for AWS APIs reachable from the cluster's private subnets. Keeps that traffic off the NAT gateway.

Each interface endpoint in `endpoint_host_offsets` of [`pipelines/network.hcl`](../../../pipelines/network.hcl) gets a fixed `/32` IP pinned on its ENI in each subnet of [`../endpoint_cidrs`](../endpoint_cidrs/), so a `CiliumNetworkPolicy` can scope its egress rule to that single address instead of every public IP. `s3` is a gateway endpoint (route table prefix-list entry, no ENI), so it has no IP to pin.

## Critical Pods

Only the AWS APIs a critical pod calls get an interface endpoint. A pod is critical if its IAM role can read secrets, change DNS, launch compute, pass IAM roles, or change network exposure (load balancers, security groups). Every other pod reaches AWS APIs through its public egress rule (`toCIDRSet` on `0.0.0.0/0`, with RFC1918 in `except`).

Private DNS resolves an API with an endpoint to the endpoint IPs for every pod. A non-critical pod calling that API still needs a `toCIDR` rule on them.

## Adding an Interface Endpoint

Add an entry to `local.endpoint_host_offsets` in [`pipelines/network.hcl`](../../../pipelines/network.hcl), with an offset unused by any other entry. That offset is read by both this unit and [`../endpoint_cidrs`](../endpoint_cidrs/), which is what actually computes the pinned IP. That's enough to get the endpoint and its pinned IP created.

For the critical pod's `CiliumNetworkPolicy` to use that IP, also add the service to `local.app_param_key_map` in the same file, under the consumer-side key its CNP expects, then thread `dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs` into the consuming app's `appParams` entry (see `units/eks/addons/argocd/app_of_apps/terragrunt.hcl`) per [Pass Terraform Values to an App](https://eks-forge.readthedocs.io/latest/docs/applications/pass-terraform-values-to-an-app/).
