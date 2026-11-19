locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  # Every optional feature stack of pipelines/dev/eks/stack/terragrunt.stack.hcl.
  features = ["example"]
}

stack "feature_toggles" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//stacks/feature_toggles?ref=${local.version}"
  path   = "feature_toggles"

  values = {
    version                  = local.version
    github_owner_catalog     = local.github_owner_catalog
    github_repo_name_catalog = local.github_repo_name_catalog
    github_token             = get_env("GITHUB_TOKEN")
    github_repo_name         = local.github_repo_name_catalog
    enabled_features         = [for f in local.features : f if get_env("FEATURE_${upper(f)}_ENABLED", "false") == "true"]
  }
}
