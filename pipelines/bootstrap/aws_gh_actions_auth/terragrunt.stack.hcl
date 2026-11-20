locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  github_token = get_env("GITHUB_TOKEN")

  # GitHub's `sub` prefix for the repository. Holds owner and repo IDs with immutable subject claims.
  subject_claim_prefix = run_cmd("--terragrunt-quiet", "gh", "api", "repos/${local.github_owner_catalog}/${local.github_repo_name_catalog}/actions/oidc/customization/sub", "--jq", ".sub_claim_prefix // error(\"sub_claim_prefix missing from GitHub API response\")")
}

stack "aws_gh_actions_auth" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//stacks/aws_gh_actions_auth?ref=${local.version}"
  path   = "github_actions_bootstrap"
  values = {
    version                  = local.version
    github_owner_catalog     = local.github_owner_catalog
    github_repo_name_catalog = local.github_repo_name_catalog
    github_repo_name         = local.github_repo_name_catalog
    github_token             = local.github_token
    oidc_url                 = "https://token.actions.githubusercontent.com"
    oidc_client_id_list      = ["sts.amazonaws.com"]
    oidc_thumbprint_list     = []
    create_oidc_provider     = true
    deploy_key_repositories  = [local.github_repo_name_catalog]
    deploy_key_secret_names  = ["DEPLOY_KEY_TG_CATALOG"]
    deploy_key_title         = "Terragrunt Catalog Deploy Key"
  }
}

stack "aws_gh_actions_role" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//stacks/aws_gh_actions_role?ref=${local.version}"
  path   = "github_actions_role"
  values = {
    version                  = local.version
    github_owner_catalog     = local.github_owner_catalog
    github_repo_name_catalog = local.github_repo_name_catalog
    github_owner             = local.github_owner_catalog
    github_repo_name         = local.github_repo_name_catalog
    subject_claim_prefix     = local.subject_claim_prefix
    github_branch            = "*"
    github_token             = local.github_token
    iam_role_name            = "gh-terragrunt-role-catalog"
    # CI only plans.
    read_only         = true
    plan_secret_names = [local.github_locals.app_of_apps_deploy_key_secret_name]
  }
}

unit "deploy_key_terraform_docs" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//units/github/deploy_key/?ref=${local.version}"
  path   = "github/deploy_key"

  values = {
    version            = local.version
    github_token       = local.github_token
    repositories       = [local.github_repo_name_catalog]
    current_repository = local.github_repo_name_catalog
    secret_names       = ["TERRAFORM_DOCS_DEPLOY_KEY"]
    deploy_key_title   = "Terraform Docs Deploy Key"
    read_only          = false
  }
}
