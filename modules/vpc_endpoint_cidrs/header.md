# `vpc_endpoint_cidrs` Terraform Module Reference

The [`vpc_endpoint_cidrs` module](../vpc_endpoint_cidrs/) computes the pinned ENI IP of each interface VPC endpoint from a private subnet CIDR and a per-service host offset, and creates no resources. It is the single source of the `cidrhost()` math read by [`units/vpc/endpoints`](../../units/vpc/endpoints/), which pairs each IP with its subnet ID, and by [`units/eks/addons/argocd/app_of_apps`](../../units/eks/addons/argocd/app_of_apps/), which passes the plain IP list as the `vpcEndpointCidrs` app parameter of a `CiliumNetworkPolicy`.
