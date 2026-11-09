# VPC Endpoint CIDRs

Wraps [`modules/vpc_endpoint_cidrs`](../../../modules/vpc_endpoint_cidrs/), which pins each interface VPC endpoint's ENI IP from the VPC's private subnet CIDRs and the offsets in [`pipelines/network.hcl`](../../../pipelines/network.hcl).

`values.endpoint_az_count` limits the IPs to the first N private subnets, and every private subnet is used when it's unset. [`../endpoints`](../endpoints/) places each endpoint's ENIs in those same subnets, so the ENIs, the reservations, and the `CiliumNetworkPolicy` IP lists cover the same AZs.

Reserves the range holding those IPs in each of those subnets with an explicit [subnet CIDR reservation](https://docs.aws.amazon.com/vpc/latest/userguide/subnet-cidr-reservation.html). The private subnets also host nodes and pod prefixes, and AWS never assigns a reserved address to them. An offset outside the reserved range fails the plan.

Single source of truth for that `cidrhost()` math: [`../endpoints`](../endpoints/) consumes `endpoint_ips` to build the endpoint resources, and `units/eks/addons/argocd/app_of_apps` consumes `vpc_endpoint_cidrs` to feed `CiliumNetworkPolicy` app params.
