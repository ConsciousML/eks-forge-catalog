# VPC Endpoint CIDRs

Wraps [`modules/vpc_endpoint_cidrs`](../../../modules/vpc_endpoint_cidrs/), which pins each interface VPC endpoint's ENI IP from the VPC's private subnet CIDRs and the offsets in [`pipelines/network.hcl`](../../../pipelines/network.hcl).

Reserves the range holding those IPs in each private subnet with an explicit [subnet CIDR reservation](https://docs.aws.amazon.com/vpc/latest/userguide/subnet-cidr-reservation.html). The private subnets also host nodes and pod prefixes, and AWS never assigns a reserved address to them. See [Reserved Range](#reserved-range).

Single source of truth for that `cidrhost()` math: [`../endpoints`](../endpoints/) consumes `endpoint_ips` to build the endpoint resources, and `units/eks/addons/argocd/app_of_apps` consumes `vpc_endpoint_cidrs` to feed `CiliumNetworkPolicy` app params.

## Reserved Range

A subnet CIDR reservation is one CIDR block, so it cannot cover an arbitrary span of hosts. The reserved block starts at the base of each private subnet. It is the smallest such block that holds every offset in `endpoint_host_offsets`. Its prefix length is `reservation_prefix_length` in [`modules/vpc_endpoint_cidrs/main.tf`](../../../modules/vpc_endpoint_cidrs/main.tf).

The block holds more addresses than there are pinned IPs. The spare ones are reserved ahead of time, so an endpoint added to a running environment finds its address free. A reservation per pinned IP would only exist once its endpoint does, and would leave that address open until then.

Limitations:

- The prefix length is fixed and does not follow `endpoint_host_offsets`. An offset outside the block fails the plan.
- Changing the prefix length replaces the reservation in every private subnet. The addresses are unreserved between the destroy and the create. Existing endpoints keep their IPs.
- An address already held by a node, a pod prefix, or another network interface when the reservation is created stays held. The reservation only stops new automatic assignments.
- Addresses in the block that match no offset are reserved and unused.
