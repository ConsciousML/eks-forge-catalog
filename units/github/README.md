# GitHub

Provisions the AWS and GitHub resources needed for GitHub Actions to authenticate with AWS via OIDC and access private repositories.

Run via [`pipelines/bootstrap/aws_gh_actions_auth`](../../pipelines/bootstrap/aws_gh_actions_auth/) once per repository before enabling CI. [`stacks/aws_gh_actions_auth`](../../stacks/aws_gh_actions_auth/) holds `oidc_provider` and `deploy_key`. [`stacks/aws_gh_actions_role`](../../stacks/aws_gh_actions_role/) holds `iam_role`, `iam_policies`, and `secrets/action`, once per role.

## Concepts

- [OpenID Connect (OIDC) in GitHub Actions](https://docs.github.com/en/actions/concepts/security/openid-connect)
- [AWS IAM OIDC identity providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub Deploy Keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys)

## What's Inside

- **[oidc_provider](oidc_provider/)**: Creates an [AWS IAM OpenID Connect provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) that declares GitHub Actions as a trusted external identity provider. Global per AWS account (set `create = false` when a second repository shares the same account)
- **[iam_role](iam_role/)**: Creates an IAM role whose trust policy is scoped to a specific GitHub repository and branch via the OIDC provider. With `read_only`, adds the `TerragruntPlan` inline policy (state lock, state KMS key, and `plan_secret_names`), built from the caller's `root.hcl`
- **[iam_policies](iam_policies/)**: Attaches managed IAM policy ARNs to the role from `iam_role`, granting the permissions Terragrunt needs to run in CI. With `read_only`, attaches `ReadOnlyAccess`
- **[secrets/action](secrets/action/)**: Stores `iam_role`'s ARN (in `role_arn_secret_name`, default `AWS_ROLE_ARN`) and, with `write_region`, the region as GitHub Actions secrets so workflows can assume the role without hardcoded credentials
- **[secrets/eks_local_admin](secrets/eks_local_admin/)**: Stores `EKS_LOCAL_ADMIN_ARN` as a GitHub Actions secret. The [CD workflow](https://github.com/ConsciousML/eks-forge-live/blob/main/.github/workflows/cd.yaml) reads it via `get_env` and injects it into the cluster `access_entries` (see [prod EKS stack](https://github.com/ConsciousML/eks-forge-live/blob/main/live/prod/eks/terragrunt.stack.hcl)), so the local admin retains kubectl access after CI deploys the cluster
- **[variables/feature_toggles](variables/feature_toggles/)**: Stores a `FEATURE_<NAME>_ENABLED` GitHub Actions variable for each enabled optional feature. Run via [`pipelines/bootstrap/feature_toggles`](../../pipelines/bootstrap/feature_toggles/). [`.github/actions/setup`](../../.github/actions/setup/) exports every `FEATURE_` variable in CI
- **[deploy_key](deploy_key/)**: Generates SSH deploy keys and registers them on target repositories, enabling Terragrunt to pull code from private repositories during CI. Instantiated in the bootstrap stack once read-only (remote sources) and once with write access (terraform-docs commits)

## Upstream Dependencies

- **[`units/aws_caller_identity`](../aws_caller_identity/)**: `secrets/eks_local_admin` reads its `arn` output to populate `EKS_LOCAL_ADMIN_ARN`
