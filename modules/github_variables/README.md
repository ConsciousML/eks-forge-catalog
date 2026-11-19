<!-- BEGIN_TF_DOCS -->
# `github_variables` Terraform Module Reference

The [`github_variables` module](../github\_variables/) creates a [GitHub Actions variable](https://docs.github.com/en/actions/learn-github-actions/variables) in a target repository for each entry of a name/value map.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_github"></a> [github](#requirement\_github) | = 6.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | = 6.6.0 |

## Resources

| Name | Type |
|------|------|
| [github_actions_variable.this](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/actions_variable) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub organization or user account that owns the target repository | `string` | n/a | yes |
| <a name="input_github_repo_name"></a> [github\_repo\_name](#input\_github\_repo\_name) | GitHub repository name where variables will be stored | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub personal access token with 'repo' permissions. Required to create and manage GitHub Actions variables | `string` | n/a | yes |
| <a name="input_variables"></a> [variables](#input\_variables) | Map of GitHub Actions variable names to their values | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_variables_created"></a> [variables\_created](#output\_variables\_created) | List of GitHub variables that were created |
<!-- END_TF_DOCS -->