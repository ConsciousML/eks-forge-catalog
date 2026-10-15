# The path must contain state_kms_key, which root.hcl excludes from state encryption.
unit "state_kms_key" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/state_kms_key?ref=${values.version}"
  path   = "state_kms_key"

  values = {
    version = values.version
  }
}
