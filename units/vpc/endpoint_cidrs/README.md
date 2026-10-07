# VPC Endpoint CIDRs

Wraps [`modules/vpc_endpoint_cidrs`](../../../modules/vpc_endpoint_cidrs/), which pins each interface VPC endpoint's ENI IP from the VPC's private subnet CIDRs and the offsets in [`pipelines/network.hcl`](../../../pipelines/network.hcl).

Reserves the range holding those IPs in each private subnet with an explicit [subnet CIDR reservation](https://docs.aws.amazon.com/vpc/latest/userguide/subnet-cidr-reservation.html). The private subnets also host nodes and pod prefixes, and AWS never assigns a reserved address to them. An offset outside the reserved range fails the plan.

Single source of truth for that `cidrhost()` math: [`../endpoints`](../endpoints/) consumes `endpoint_ips` to build the endpoint resources, and `units/eks/addons/argocd/app_of_apps` consumes `vpc_endpoint_cidrs` to feed `CiliumNetworkPolicy` app params.
