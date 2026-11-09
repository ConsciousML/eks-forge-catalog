include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/github_secrets?ref=${values.version}"
}

inputs = {
  github_token     = values.github_token
  github_owner     = include.root.locals.github_owner_catalog
  github_repo_name = values.github_repo_name
  secrets = {
    # `us` stands for the empty US region, since a GitHub secret can't be empty. Consumers only check for `eu`.
    PAGERDUTY_SERVICE_REGION = values.service_region == "" ? "us" : values.service_region
  }
}
