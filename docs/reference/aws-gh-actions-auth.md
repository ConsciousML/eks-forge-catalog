{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS GitHub Actions Authentication Bootstrap Reference

Two stacks provision the [OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)-based trust between GitHub Actions and AWS, letting CI assume an IAM role and run Terragrunt without long-lived AWS keys:

- [`aws_gh_actions_auth`](../../stacks/aws_gh_actions_auth/): the OIDC provider, the deploy keys, and the `AWS_REGION` secret, once per repository
- [`aws_gh_actions_role`](../../stacks/aws_gh_actions_role/): one IAM role and the GitHub Actions secret holding its ARN, once per role

The catalog pipeline ([`pipelines/bootstrap/aws_gh_actions_auth`](../../pipelines/bootstrap/aws_gh_actions_auth/terragrunt.stack.hcl)) creates one role with `read_only = true`. See [Read-Only Plan Role](#read-only-plan-role).

For setup steps, read the [AWS GitHub Actions Authentication Bootstrap](/docs/quickstart/bootstrap/aws_gh_actions_auth).

## Modules

| Stack | Name | Unit | Module |
|-------|------|------|--------|
| `aws_gh_actions_auth` | `github_oidc_provider` | [`units/github/oidc_provider`](../../units/github/oidc_provider/) | [`oidc_provider`](/docs/reference/terraform_modules/oidc_provider/) |
| `aws_gh_actions_auth` | `github_secrets_region` | [`units/github/secrets/region`](../../units/github/secrets/region/) | [`github_secrets`](/docs/reference/terraform_modules/github_secrets/) |
| `aws_gh_actions_auth` | `deploy_key` | [`units/github/deploy_key`](../../units/github/deploy_key/) | [`deploy_key`](/docs/reference/terraform_modules/deploy_key/) |
| `aws_gh_actions_role` | `iam_role_github_actions` | [`units/github/iam_role`](../../units/github/iam_role/) | [`iam_role_github_actions`](/docs/reference/terraform_modules/iam_role_github_actions/) |
| `aws_gh_actions_role` | `iam_policies` | [`units/github/iam_policies`](../../units/github/iam_policies/) | [`iam_policies`](/docs/reference/terraform_modules/iam_policies/) |
| `aws_gh_actions_role` | `github_secrets` | [`units/github/secrets/action`](../../units/github/secrets/action/) | [`github_secrets`](/docs/reference/terraform_modules/github_secrets/) |

## `aws_gh_actions_auth` Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `oidc_url` | Issuer URL of the OIDC identity provider (GitHub Actions: `https://token.actions.githubusercontent.com`). | `string` | - | Yes |
| `oidc_client_id_list` | Audiences allowed to request tokens from the OIDC provider (GitHub Actions: `["sts.amazonaws.com"]`). | `list(string)` | - | Yes |
| `oidc_thumbprint_list` | Server certificate thumbprints for the provider. Not needed for GitHub Actions, already in AWS's trusted CA library. | `list(string)` | - | Yes |
| `create_oidc_provider` | Whether to create the GitHub OIDC provider. See [OIDC Provider](#oidc-provider). | `bool` | - | Yes |
| `github_owner` | GitHub username or organization name that owns the repository. | `string` | - | Yes |
| `github_repo_name` | GitHub repository name. | `string` | - | Yes |
| `github_token` | GitHub personal access token with `repo` permissions. | `string` | - | Yes |
| `deploy_key_repositories` | Repositories granted read-only deploy key access, so Terragrunt can pull remote source code from them. | `list(string)` | - | Yes |
| `deploy_key_secret_names` | GitHub Actions secret name for each entry in `deploy_key_repositories`, same order. | `list(string)` | - | Yes |
| `deploy_key_title` | Title given to the created deploy keys. | `string` | `"Terragrunt Deploy Key"` | No |

## `aws_gh_actions_role` Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `iam_role_name` | Name of the IAM role GitHub Actions assumes. Must be unique per AWS account. | `string` | - | Yes |
| `github_owner` | GitHub username or organization name that owns the repository. | `string` | - | Yes |
| `github_repo_name` | GitHub repository name. | `string` | - | Yes |
| `github_token` | GitHub personal access token with `repo` permissions. | `string` | - | Yes |
| `subject_claim_prefix` | Prefix of the OIDC `sub` claim GitHub issues for the repository. Read from the GitHub API, so it holds the owner and repository IDs when the repository uses [immutable subject claims](https://docs.github.com/en/actions/reference/security/oidc#immutable-subject-claims). | `string` | `repo:<github_owner>/<github_repo_name>` | No |
| `github_branch` | Branch allowed to assume the role. `*` allows all branches. | `string` | - | Yes |
| `policy_arns` | IAM policy ARNs attached to the role. | `list(string)` | `[]` | No |
| `inline_policies` | Inline IAM policies (`name`, `policy` JSON) attached directly to the role. | `list(object)` | `[]` | No |
| `read_only` | Attaches the plan-only policies. See [Read-Only Plan Role](#read-only-plan-role). | `bool` | `false` | No |
| `plan_secret_names` | Secrets Manager secret names the plan reads, with `read_only`. | `list(string)` | `[]` | No |
| `max_session_duration` | Maximum session duration (seconds) for the assumed role. | `number` | `3600` | No |
| `role_arn_secret_name` | GitHub Actions secret holding the role ARN. | `string` | `"AWS_ROLE_ARN"` | No |

## OIDC Provider

The [GitHub Actions OIDC provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) is a global, AWS account-level resource. Only one can exist per AWS account.

Set `create_oidc_provider = false` when another repository already created it in the same AWS account. Setting it `true` a second time fails with `EntityAlreadyExists`. Give each repository's role a distinct `iam_role_name` to avoid conflicts.

In EKS Forge, use `create_oidc_provider = true` in your [catalog](https://github.com/ConsciousML/eks-forge-catalog) fork and `create_oidc_provider = false` and in [live](https://github.com/ConsciousML/eks-forge-live) fork.

## Read-Only Plan Role

With `read_only = true`, the role gets `ReadOnlyAccess` and a `TerragruntPlan` inline policy (see [`units/github/iam_role`](../../units/github/iam_role/terragrunt.hcl)):

- writes to the state lock table
- `kms:Decrypt` and `kms:GenerateDataKey` on the state KMS key, both read from the caller's `root.hcl`
- `secretsmanager:GetSecretValue` on `plan_secret_names`

The role can't create, change, or delete resources. It decrypts only state encrypted with its repository's state KMS key, so anyone with push access can read the secrets in that state. State encrypted with another repository's key stays unreadable.

## Multiple Roles

Each job can assume its own role. Add one `aws_gh_actions_role` stack per role, each with a distinct `iam_role_name` and `role_arn_secret_name`. For example, an `AdministratorAccess` role in `AWS_ROLE_ARN` for jobs that apply, and a `read_only` role in `AWS_PLAN_ROLE_ARN` for jobs that only plan.

A `read_only` role that plans against a running cluster also needs:

- every secret the plan refreshes in `plan_secret_names`. Each entry becomes `secret:<entry>-*`, so `<environment>-*` covers the secrets the units create.
- an EKS access entry with `AmazonEKSAdminViewPolicy` (the cluster `access_entries` value), so the Helm and Kubernetes providers can read the cluster, including Helm's release Secrets.

## GitHub Actions Workflow Setup Action

The `setup` action reads deploy keys from GitHub Actions secrets named by `deploy_key_secret_names`, one `deploy-keys` line per entry, in the same order.

Single deploy key:
```yaml
- uses: ./.github/actions/setup
  with:
    deploy-keys: ${{ secrets.YOUR_DEPLOY_KEY_NAME }}
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ secrets.AWS_REGION }}
```

Multiple deploy keys:
```yaml
- uses: ./.github/actions/setup
  with:
    deploy-keys: |
      ${{ secrets.DEPLOY_KEY_SECRET_NAME_1 }}
      ${{ secrets.DEPLOY_KEY_SECRET_NAME_2 }}
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ secrets.AWS_REGION }}
```
