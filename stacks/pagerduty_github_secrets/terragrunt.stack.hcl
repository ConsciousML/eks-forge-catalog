unit "pagerduty_github_secrets" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/pagerduty/github_secrets?ref=${values.version}"
  path   = "pagerduty/github_secrets"

  values = {
    version          = values.version
    github_token     = values.github_token
    github_repo_name = values.github_repo_name
    service_region   = values.service_region
  }
}
