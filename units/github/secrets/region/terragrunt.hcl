include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/github_secrets?ref=${values.version}"
}

inputs = {
  github_token     = values.github_token
  github_owner     = values.github_owner
  github_repo_name = values.github_repo_name
  secrets          = { AWS_REGION = include.root.locals.aws_region }
}
