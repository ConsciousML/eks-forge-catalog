{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

This guide shows you how to remove a [unit](/docs/iac/#units) from your [forked catalog](/docs/quickstart/installation/#fork-the-eks-forge-catalog), validate the removal in [`dev`](/docs/iac/#dev), and merge it.

First, create a branch in your forked catalog:
```bash
git checkout -b <branch>
```

## Destroy the Dev Stack

If your dev stack is running, destroy it before changing anything. Once the unit's block is gone, `run --all` no longer sees the unit, so its resources would stay in AWS and keep being billed. From the repository root:
```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack clean
terragrunt stack generate
terragrunt run --all destroy --non-interactive --no-stack-generate
```

## Drop Its Dependents

In each unit that has a [`dependency`](https://docs.terragrunt.com/reference/hcl/blocks/#dependency) block pointing at yours, delete that block and every line that reads its outputs.

If `argocd_app_of_apps` is among them, it passes your unit's outputs to an app through [`appParams`](/docs/applications/how-the-app-of-apps-works/#appparams-injection). Remove that app first, by following [Add, Edit, or Remove an App](/docs/applications/add-edit-or-remove-an-app/), or change it so it no longer needs them.

## Delete the Unit

In [`pipelines/dev/eks/stack/terragrunt.stack.hcl`](https://github.com/ConsciousML/eks-forge-catalog/tree/main/pipelines/dev/eks/stack/terragrunt.stack.hcl), delete your unit's `unit` block. If the block read a `version_<name>` local that no other block uses, delete the local too.

If no other stack uses the unit, delete its directory, with its README and lock file, replacing `<unit-dir>` with its path under `units/`:
```bash
git rm -r units/<unit-dir>
```

If the unit sourced a module under `modules/` or a chart under `charts/` that no other unit uses, delete it too:
```bash
git rm -r modules/<name> # or charts/<name>
```

## Validate in Dev

Follow [Validate in Dev](/docs/iac/add-a-unit/#validate-in-dev). The apply fails if a unit still depends on the removed one. Instead of checking that the resource exists, check that it's gone. For example, for the Loki S3 chunks bucket, this prints nothing:
```bash
aws s3 ls | grep dev-loki-chunks
```

## Open a Pull Request and Merge

Follow [Open a Pull Request](/docs/iac/add-a-unit/#open-a-pull-request) and [Merge](/docs/iac/add-a-unit/#merge).

To remove the unit from `staging` and `prod`, see [Release a Change to Production](/docs/deployment/release-a-change-to-production/). Its resources stay in `prod` until you follow [Destroy Removed Units](/docs/iac/release-an-iac-change/#destroy-removed-units).
