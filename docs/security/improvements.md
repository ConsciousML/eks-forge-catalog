{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

# Security Improvements

Optional hardening steps you can apply on top of a [deployment](/docs/quickstart/deployment/).

## Disable the Public EKS Endpoint

For improved security, set `endpoint_public_access` to `false` in the `cluster` unit's `values` block of your [environment](/docs/iac/#environments)'s `eks/stack/terragrunt.stack.hcl` file:

```hcl
unit "cluster" {
  ...
  values = {
    ...
    endpoint_public_access = false
  }
}
```

Then re-apply the stack:
- `dev`: see [Run the Terragrunt Stack](/docs/quickstart/deployment/#run-the-terragrunt-stack).
- `staging` and `prod`: see [Release a Change to Production](/docs/deployment/release-a-change-to-production/).

From this point on, `kubectl` and the AWS CLI can only reach the API server while connected to Tailscale.

:::warning
Set `endpoint_public_access` back to `true` and re-apply the `cluster` unit before destroying the stack (see [Destroy the Infrastructure](/docs/quickstart/deployment/#destroy-the-infrastructure)). Destroying it removes the [Tailscale components](/docs/networking/tailscale/), your only path back into the cluster API while the endpoint is private.
:::

## Restrict Tailnet Access to the VPCs

By default, every member of your tailnet reaches every environment's VPC on every port (see [Access Control (ACL) Policy](/docs/networking/tailscale/#1-access-control-acl-policy)). To restrict it, replace that default with explicit [grants](https://tailscale.com/docs/features/access-control/grants).

In your catalog fork, add a `grants` list to the `acl` value of `pipelines/bootstrap/tailscale/acl/terragrunt.stack.hcl`:

```hcl
unit "acl" {
  ...
  values = {
    ...
    acl = jsonencode({
      tagOwners     = { ... }
      autoApprovers = { ... }
      grants = [
        # your grants here
      ]
    })
    ...
  }
}
```

To write your grants, follow Tailscale's [grants syntax](https://tailscale.com/docs/reference/syntax/grants) and its [VPC access example](https://tailscale.com/docs/how-to/connect-vpc). Use the VPC CIDRs in `local.vpc_cidrs` as destinations.

:::warning
Once the policy has a grant, Tailscale denies all traffic that no grant allows, including traffic between your members' own devices. Grant `local.ci_tag` access to every VPC CIDR: without it, CI and the [infrastructure tests](/docs/ci-cd/testing/how-the-infrastructure-tests-work/) can't reach the private endpoints.
:::

Then, re-apply the ACL from the root of your catalog fork, as in [Tailscale Bootstrap](/docs/quickstart/bootstrap/tailscale/).

The ACL covers the whole tailnet, so the grants also apply to `staging` and `prod`.
