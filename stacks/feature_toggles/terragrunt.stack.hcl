unit "feature_toggles" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/github/variables/feature_toggles?ref=${values.version}"
  path   = "feature_toggles"

  values = {
    version          = values.version
    github_token     = values.github_token
    github_repo_name = values.github_repo_name
    enabled_toggles  = values.enabled_toggles
  }
}
