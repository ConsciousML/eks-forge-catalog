{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# App of Apps Deploy Key Bootstrap Reference

The [`app_of_apps_deploy_key` pipeline](../../pipelines/bootstrap/app_of_apps_deploy_key/) adds two deploy keys to the app of apps fork set in [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl). Environment-independent, run once.

- `deploy_key_helm_docs`: a write key. Its private key is a GitHub Actions secret on the same fork, so its CI can push the generated chart READMEs back to PRs.
- `deploy_key_argocd`: a read-only key. Its private key is in the AWS Secrets Manager secret named `app_of_apps_deploy_key_secret_name` in `github.hcl`. The [`argocd/repository_secret`](../../units/eks/addons/argocd/repository_secret/) unit reads it when `app_of_apps_private` is `true`, so ArgoCD can read a private fork.

For setup steps, read [Enable README Generation in CI](/docs/applications/get-started/app-of-apps-setup/#enable-readme-generation-in-ci).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `deploy_key_helm_docs` | [`units/github/deploy_key`](../../units/github/deploy_key/) | [`deploy_key`](/docs/reference/terraform_modules/deploy_key/) |
| `deploy_key_argocd` | [`units/github/deploy_key`](../../units/github/deploy_key/) | [`deploy_key`](/docs/reference/terraform_modules/deploy_key/) |

## Values

The pipeline sets these values on the units. For every input and output, read the [`deploy_key`](/docs/reference/terraform_modules/deploy_key/) module reference.

| Name | `deploy_key_helm_docs` | `deploy_key_argocd` |
|------|-------|-------|
| `github_owner` | `github_owner_app_of_apps` from [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl) | Same |
| `repositories` | `[github_repo_name_app_of_apps]` from [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl) | Same |
| `current_repository` | `github_repo_name_app_of_apps` from [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl) | Unset |
| `secret_names` | `["HELM_DOCS_DEPLOY_KEY"]` | Unset |
| `deploy_key_title` | `"Helm Docs Deploy Key"` | `"ArgoCD Deploy Key"` |
| `read_only` | `false` | `true` |
| `aws_secret_name` | Unset | `app_of_apps_deploy_key_secret_name` from [`github.hcl`](/docs/reference/hcl_configuration/#githubhcl) |
