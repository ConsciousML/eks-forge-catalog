locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals.environment
}

# Alias and path must match state_kms_key_arn and state_encryption in root.hcl.
unit "state_kms_key" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/kms_key?ref=${values.version}"
  path   = "state_kms_key"

  values = {
    version     = values.version
    alias_name  = "alias/${local.environment}-tofu-state"
    description = "Encrypts OpenTofu state and plan files"
  }
}
