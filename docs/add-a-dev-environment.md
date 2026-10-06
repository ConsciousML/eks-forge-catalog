{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

This guide shows you how to deploy a second [`dev`](/docs/iac/#dev)-like environment from your [forked catalog](/docs/quickstart/installation/#fork-the-eks-forge-catalog) (e.g. `dev-2`), running next to `dev`. It deploys the same stack under another name, with its own state, VPC, cluster, hosted zone, and Slack channels.

It assumes you've already deployed `dev` once, as in [Dev Deployment](/docs/quickstart/deployment/).

First, create a branch in your forked catalog and push it, replacing `<branch>`. The pipelines fetch their units from git at your current branch, so it must exist on GitHub:
```bash
git checkout -b <branch>
git push -u origin <branch>
```

Then add your environment's name as [`TG_ENVIRONMENT`](/docs/reference/environment_variable/#tg_environment-and-tg_environment_alias) to your `.env` file, replacing `<environment>` (e.g. `dev-2`). Use only lowercase letters, digits, and hyphens, since it ends up in bucket names and hostnames:
```bash
export TG_ENVIRONMENT=<environment>
```

Then load it, from the root of your catalog fork:
```bash
source .env
```

From now on, every command run after `source .env` targets your environment instead of `dev`. To go back, see [Switch Between Environments](#switch-between-environments).

## Reserve a VPC CIDR

Add your environment to `vpc_cidrs` in [`pipelines/network.hcl`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/blob/main/pipelines/network.hcl), with the `/16` block that follows the highest one. For example, for `dev-2`:
```hcl
vpc_cidrs = {
  ...
  catalog-eks-ci = "10.3.0.0/16"
  dev-2          = "10.4.0.0/16"
}
```

The stack reads its VPC CIDR from this entry, so the apply fails without it. The block must not overlap another environment's, since Tailscale routes each VPC by its CIDR.

:::warning
Each environment takes a whole `/16` block, and `10.0.0.0/8` holds 256 of them (`10.0.0.0/16` to `10.255.0.0/16`). If you add several environments, make sure a free block is left for each one.
:::

## Approve the CIDR in Tailscale

The [Tailscale ACL](/docs/reference/bootstrap/tailscale_acl/) pipeline builds `autoApprovers` from `vpc_cidrs`. Without your CIDR in it, the environment's [Tailscale Connector](/docs/security/tailscale/#4-connector-and-split-dns) can't route traffic into its VPC. From the root of your catalog fork, apply it again:
```bash
source .env
cd pipelines/bootstrap/tailscale/acl
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

## Create the Hosted Zone

Each environment gets its own public hosted zone, at `<environment>.<base_domain>`. From the root of your catalog fork, copy the one of `dev`:
```bash
cp -r pipelines/bootstrap/setup_dns/dev pipelines/bootstrap/setup_dns/$TG_ENVIRONMENT
```

In its `environment.hcl`, set `environment` to your environment's name. For example, for `dev-2`:
```hcl
# pipelines/bootstrap/setup_dns/dev-2/environment.hcl

locals {
  environment       = "dev-2"
  environment_alias = local.environment
}
```

Then apply it:
```bash
source .env
cd pipelines/bootstrap/setup_dns/$TG_ENVIRONMENT
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Finally, add the hosted zone's NS records in your domain registrar, by following [DNS Bootstrap](/docs/quickstart/bootstrap/setup_dns/) from the step that retrieves the nameservers. Without them, ACM can't validate the environment's TLS certificate.

## Create the Slack Channels

Alertmanager posts to channels prefixed with the environment's name (e.g. `dev-2-k8s-critical`). From the root of your catalog fork, copy the channels pipeline of `dev`:
```bash
cp -r pipelines/bootstrap/slack/channels/dev pipelines/bootstrap/slack/channels/$TG_ENVIRONMENT
```

Set `environment` in its `environment.hcl`, as in [Create the Hosted Zone](#create-the-hosted-zone). Then apply it:
```bash
source .env
cd pipelines/bootstrap/slack/channels/$TG_ENVIRONMENT
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Finally, join the new channels in your Slack workspace, as in [Slack Bootstrap](/docs/quickstart/bootstrap/slack/).

## Check Quota Headroom

The EC2 quotas are shared by every environment of your AWS account, and a second cluster adds its own vCPUs to them. Before you deploy, follow [Check Quota Headroom First](/docs/compute/increase-ec2-capacity/#check-quota-headroom-first).

## Deploy the Environment

Your environment has no [environment overlays](/docs/applications/how-the-app-of-apps-works/#environment-overlays) of its own, so every app with one would fail to sync. Load the ones of `dev` instead, by adding this to your `.env` file:
```bash
export TG_ENVIRONMENT_ALIAS=dev
```

To give it its own overlays instead, see [Configure an App per Environment](/docs/applications/configure-an-app-per-environment/).

Then deploy the dev stack under your environment's name, from the root of your catalog fork:
```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

When it's done, connect `kubectl` to your environment's cluster, replacing `<region-code>` with the region set in [`pipelines/region.hcl`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/blob/main/pipelines/region.hcl):
```bash
aws eks update-kubeconfig --region <region-code> --name $TG_ENVIRONMENT-cluster
```

Then check the deployment by following the quickstart from [Deploy Applications with ArgoCD](/docs/quickstart/deployment/#deploy-applications-with-argocd), replacing `dev` with your environment's name in every hostname and secret name (e.g. `argocd.private.dev-2.<base_domain>` and `dev-2-argocd-password`).

The cluster's API endpoint is public, like the one of `dev`. To make it private, see [Disable the Public EKS Endpoint](/docs/security/improvements/#disable-the-public-eks-endpoint).

## Switch Between Environments

While `TG_ENVIRONMENT` and `TG_ENVIRONMENT_ALIAS` are in your `.env`, every command targets your environment instead of `dev`. To target `dev` again, comment them out in your `.env`, then unset them:
```bash
unset TG_ENVIRONMENT TG_ENVIRONMENT_ALIAS
```

To target your environment again, uncomment them and run `source .env`.

:::warning
Both environments generate their stack into the same `pipelines/dev/eks/stack/.terragrunt-stack/` directory. After switching, always run `terragrunt stack clean` and `terragrunt stack generate` before any other command. Never run Terragrunt for both environments at the same time from one clone of your fork. Use a second clone instead.
:::

Before an apply or a destroy, check which environment your shell targets. This prints nothing for `dev`:
```bash
echo $TG_ENVIRONMENT
```

## Open a Pull Request and Merge

From the root of your catalog fork, commit the CIDR and the two bootstrap folders, replacing `<message>`:
```bash
git add pipelines/
git commit -m "<message>" # e.g. "feat: add dev-2 environment"
```

Then follow [Open a Pull Request](/docs/iac/add-a-unit/#open-a-pull-request) and [Merge](/docs/iac/add-a-unit/#merge). You have nothing to release to `staging` and `prod`: the environment only exists in your catalog fork.

## Destroy the Environment

Once you're done with the environment, destroy its stack to stop paying for it. Like for `dev`, disconnect from Tailscale first, by running `tailscale down` or with the button in the Tailscale client. Then, with `TG_ENVIRONMENT` in your `.env`, run the following from the root of your catalog fork:
```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack clean
terragrunt stack generate
terragrunt run --all destroy --non-interactive --no-stack-generate
```

Its hosted zone and Slack channels stay in place, so you can deploy it again later. Only the hosted zone is billed. Until then, target `dev` again, as in [Switch Between Environments](#switch-between-environments).

## Remove the Environment

To remove the environment for good, first [destroy its stack](#destroy-the-environment). Then destroy its two bootstrap pipelines, from the root of your catalog fork:
```bash
source .env
cd pipelines/bootstrap/setup_dns/$TG_ENVIRONMENT
terragrunt run --all destroy --non-interactive
cd ../../slack/channels/$TG_ENVIRONMENT
terragrunt run --all destroy --non-interactive
```

Then:
1. Remove its NS records in your domain registrar. Left in place, they point your subdomain at name servers you no longer control, which can let someone else take it over.
2. Delete its state bucket, `tofu-state-<account-id>-<region>-<environment>`. It's versioned, so empty it from the [S3 console](https://console.aws.amazon.com/s3/buckets) first.
3. Delete its two bootstrap folders and its entry in `vpc_cidrs`.
4. Apply the ACL again, as in [Approve the CIDR in Tailscale](#approve-the-cidr-in-tailscale).
5. Merge the change, as in [Open a Pull Request and Merge](#open-a-pull-request-and-merge).
6. Remove `TG_ENVIRONMENT` and `TG_ENVIRONMENT_ALIAS` from your `.env`, then unset them, as in [Switch Between Environments](#switch-between-environments). Otherwise your next commands still target the environment you removed.
