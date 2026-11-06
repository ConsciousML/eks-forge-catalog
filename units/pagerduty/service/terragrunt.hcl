include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/pagerduty_service?ref=${values.version}"
}

inputs = {
  token          = values.token
  service_region = values.service_region
  environment    = values.environment
}
