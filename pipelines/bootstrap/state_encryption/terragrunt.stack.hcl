locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals.environment
}

# Alias must match state_kms_key_alias in root.hcl, which leaves this unit's state unencrypted.
unit "state_kms_key" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//units/kms_key/?ref=${local.version}"
  path   = "state_kms_key"

  values = {
    version     = local.version
    alias_name  = "alias/${local.environment}-tofu-state"
    description = "Encrypts OpenTofu state and plan files"
  }
}
