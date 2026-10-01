{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# App of Apps Deploy Key Bootstrap Reference

The [`app_of_apps_deploy_key` pipeline](../../pipelines/bootstrap/app_of_apps_deploy_key/) adds a write deploy key to the app of apps fork set in [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl), and stores its private key as a GitHub Actions secret on the same fork, so its CI can push the generated chart READMEs back to PRs. Environment-independent, run once.

For setup steps, read [Enable README Generation in CI](/docs/applications/get-started/app-of-apps-setup/#enable-readme-generation-in-ci).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `deploy_key_helm_docs` | [`units/github/deploy_key`](../../units/github/deploy_key/) | [`deploy_key`](/docs/reference/terraform_modules/deploy_key/) |

## Values

The pipeline sets these values on the unit. For every input and output, read the [`deploy_key`](/docs/reference/terraform_modules/deploy_key/) module reference.

| Name | Value |
|------|-------|
| `github_owner` | `github_owner_app_of_apps` from [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl) |
| `repositories` | `[github_repo_name_app_of_apps]` from [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl) |
| `current_repository` | `github_repo_name_app_of_apps` from [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl) |
| `secret_names` | `["HELM_DOCS_DEPLOY_KEY"]` |
| `deploy_key_title` | `"Helm Docs Deploy Key"` |
| `read_only` | `false` |
