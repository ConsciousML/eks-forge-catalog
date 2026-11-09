{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# PagerDuty GitHub Secrets Bootstrap Reference

The [`pagerduty_github_secrets` stack](../../stacks/pagerduty_github_secrets/), deployed by the [`pagerduty/gh_secret` pipeline](../../pipelines/bootstrap/pagerduty/gh_secret/), pushes `PAGERDUTY_SERVICE_REGION` into this repository's GitHub Actions secrets, so CI-driven environments send events to the Events API endpoint of the account's region. An empty (US) region is stored as `us`, since a GitHub secret can't be empty. Environment-independent, run once.

For setup steps, read the [PagerDuty Bootstrap](/docs/quickstart/bootstrap/pagerduty).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `pagerduty_github_secrets` | [`units/pagerduty/github_secrets`](../../units/pagerduty/github_secrets/) | [`github_secrets`](/docs/reference/terraform_modules/github_secrets/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `github_token` | GitHub personal access token with `repo` permissions. | `string` | - | Yes |
| `github_repo_name` | GitHub repository name where `PAGERDUTY_SERVICE_REGION` is stored. | `string` | - | Yes |
| `service_region` | Service region of the PagerDuty account, from [`PAGERDUTY_SERVICE_REGION`](/docs/reference/environment_variable/#pagerduty_token-and-pagerduty_service_region). Empty for US, `eu` for EU. | `string` | `""` | No |

## Outputs

| Name | Description |
|------|-------------|
| `secrets_created` | List of GitHub secrets that were created. |
