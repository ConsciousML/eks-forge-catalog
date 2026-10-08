# VPC

Provisions the VPC that hosts the EKS cluster, its outbound NAT path, and the AWS-service reachability that keeps cluster traffic off that NAT path.

## What's Inside

- **[vpc](vpc/)**: Wraps [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to create the VPC and subnets
- **[endpoint_cidrs](endpoint_cidrs/)**: Pins each interface VPC endpoint's ENI IP from a private subnet CIDR and a per-service host offset, and reserves those IPs in each private subnet. Single source of truth for both `endpoints` and consumers in `eks-forge-app-of-apps`
- **[endpoints](endpoints/)**: Wraps [terraform-aws-modules/vpc//modules/vpc-endpoints](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest/submodules/vpc-endpoints) to provision the actual VPC endpoints, using the pinned IPs from `endpoint_cidrs`
