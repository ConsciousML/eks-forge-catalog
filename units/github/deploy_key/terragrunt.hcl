include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/deploy_key/?ref=${values.version}"
}

inputs = {
  github_token       = values.github_token
  github_owner       = try(values.github_owner, include.root.locals.github_owner_catalog)
  repositories       = values.repositories
  secret_names       = try(values.secret_names, [])
  current_repository = try(values.current_repository, null)
  aws_secret_name    = try(values.aws_secret_name, null)
  deploy_key_title   = values.deploy_key_title
  read_only          = values.read_only
}