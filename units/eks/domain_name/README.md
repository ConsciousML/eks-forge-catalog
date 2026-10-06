{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

This guide shows you how to add a `domain_name_<tool>` [unit](/docs/iac/#units) to your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog). The infrastructure tests read each tool's hostname from the `value` output of its unit, so you need one before you [add an endpoint check](/docs/ci-cd/add-an-infrastructure-test/#add-an-endpoint-check) for your tool.

It assumes your tool's hostname is in `domains.hcl`, as in [Add the Hostname](/docs/applications/expose-an-app/#add-the-hostname), and that you've created a branch in your catalog fork.

## Write the Unit

From the root of your catalog fork, copy an existing unit with its lock file, replacing `<tool>`:
```bash
cp -r units/eks/domain_name/podinfo units/eks/domain_name/<tool>
```

In `units/eks/domain_name/<tool>/terragrunt.hcl`, read your tool's hostname from `domains.hcl` instead of podinfo's, and pass it as `value`. For example, for Goldilocks, in [`goldilocks/terragrunt.hcl`](goldilocks/terragrunt.hcl):
```hcl
locals {
  domains_hcl               = find_in_parent_folders("domains.hcl")
  domain_private_goldilocks = read_terragrunt_config(local.domains_hcl).locals.domain_private_goldilocks
}

inputs = {
  value = local.domain_private_goldilocks
}
```

## Add the Unit to the Dev Stack

Add its `unit` block to [`pipelines/dev/eks/stack/terragrunt.stack.hcl`](../../../pipelines/dev/eks/stack/terragrunt.stack.hcl). Name the block `domain_name_<tool>`: the tests look the unit up by that name. For example, for Goldilocks:
```hcl
unit "domain_name_goldilocks" {
  source = "${get_repo_root()}/units/eks/domain_name/goldilocks"
  path   = "eks/domain_name/goldilocks"

  values = {
    version = local.version
  }
}
```

Then follow [Validate in Dev](/docs/iac/add-a-unit/#validate-in-dev), [Open a Pull Request](/docs/iac/add-a-unit/#open-a-pull-request), and [Merge](/docs/iac/add-a-unit/#merge).

## Ship the Unit to Staging and Prod

Follow [Release a Change to Production](/docs/deployment/release-a-change-to-production/). In its [Release an IaC Change](/docs/iac/release-an-iac-change/) step, the unit's block goes into both stack files as in [Added Units](/docs/iac/release-an-iac-change/#added-units), and your tool's hostname into the `domains.hcl` of each environment as in [Update the Shared Configuration](/docs/iac/release-an-iac-change/#update-the-shared-configuration).

Before you open the pull request in your live fork, continue at [Add an Endpoint Check](/docs/ci-cd/add-an-infrastructure-test/#add-an-endpoint-check).
