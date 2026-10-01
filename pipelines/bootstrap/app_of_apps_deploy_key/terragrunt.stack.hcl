locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals                = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog         = local.github_locals.github_owner_catalog
  github_repo_name_catalog     = local.github_locals.github_repo_name_catalog
  github_owner_app_of_apps     = local.github_locals.github_owner_app_of_apps
  github_repo_name_app_of_apps = local.github_locals.github_repo_name_app_of_apps

  github_token = get_env("GITHUB_TOKEN")
}

unit "deploy_key_helm_docs" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//units/github/deploy_key/?ref=${local.version}"
  path   = "github/deploy_key"

  values = {
    version            = local.version
    github_token       = local.github_token
    github_owner       = local.github_owner_app_of_apps
    repositories       = [local.github_repo_name_app_of_apps]
    current_repository = local.github_repo_name_app_of_apps
    secret_names       = ["HELM_DOCS_DEPLOY_KEY"]
    deploy_key_title   = "Helm Docs Deploy Key"
    read_only          = false
  }
}
