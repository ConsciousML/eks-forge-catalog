locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog
}

stack "state_encryption" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//stacks/state_encryption?ref=${local.version}"
  path   = "state_encryption"
  values = {
    version                  = local.version
    github_owner_catalog     = local.github_owner_catalog
    github_repo_name_catalog = local.github_repo_name_catalog
  }
}
