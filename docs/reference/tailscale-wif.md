{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Tailscale WIF Bootstrap Reference

The [`tailscale_wif` stack](../../stacks/tailscale_wif/), deployed by the [`tailscale/wif` pipeline](../../pipelines/bootstrap/tailscale/wif/), creates a Tailscale [Workload Identity Federation](https://tailscale.com/docs/features/workload-identity-federation) credential scoped to this GitHub repository via OIDC, and stores its client ID and audience as GitHub Actions secrets, so CI authenticates to Tailscale using short-lived tokens instead of a stored OAuth secret.

For setup steps, read the [Tailscale Bootstrap](/docs/quickstart/bootstrap/tailscale).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `tailscale_wif` | [`units/tailscale/workflow_identity_federation`](../../units/tailscale/workflow_identity_federation/) | [`tailscale_wif`](/docs/reference/terraform_modules/tailscale_wif/) |
| `tailscale_github_secrets` | [`units/tailscale/github_secrets`](../../units/tailscale/github_secrets/) | [`github_secrets`](/docs/reference/terraform_modules/github_secrets/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `issuer` | OIDC issuer URL for the federated identity. | `string` | - | Yes |
| `github_owner` | GitHub organization or user account that owns the repository. Combined with `github_repo_name` to build the OIDC subject claim (`repo:<org>/<repo>:*`) scoping the credential to this repository, unless `subject_claim_prefix` is set. | `string` | - | Yes |
| `subject_claim_prefix` | Prefix of the OIDC `sub` claim GitHub issues for the repository. Read from the GitHub API, so it holds the owner and repository IDs when the repository uses [immutable subject claims](https://docs.github.com/en/actions/reference/security/oidc#immutable-subject-claims). | `string` | `repo:<github_owner>/<github_repo_name>` | No |
| `scopes` | OAuth scopes for auth keys issued via this federated identity. | `set(string)` | `["devices:core", "auth_keys", "dns"]` | No |
| `github_token` | GitHub personal access token with `repo` permissions. | `string` | - | Yes |
| `github_repo_name` | GitHub repository name where `TS_OAUTH_CLIENT_ID`, `TS_AUDIENCE`, and `TS_TAGS` are stored. | `string` | - | Yes |
| `ci_tag` | Tailscale tag assigned to CI runner devices joining via WIF. Must already be a `tagOwner` in the ACL applied by the [`tailscale/acl` pipeline](/docs/reference/bootstrap/tailscale_acl/). | `string` | `"tag:ci"` | No |

## Outputs

| Name | Description |
|------|-------------|
| `client_id` | The WIF OAuth client ID. |
| `audience` | The WIF audience value (`api.tailscale.com/<client_id>`). |
