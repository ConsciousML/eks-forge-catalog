unit "pagerduty_service" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/pagerduty/service?ref=${values.version}"
  path   = "pagerduty/service"

  values = {
    version        = values.version
    token          = values.token
    service_region = values.service_region
    environment    = values.environment
  }
}

unit "pagerduty_aws_secret" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/pagerduty/aws_secret?ref=${values.version}"
  path   = "pagerduty/aws_secret"

  values = {
    version     = values.version
    environment = values.environment
  }
}
