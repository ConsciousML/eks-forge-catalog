include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/github_variables?ref=${values.version}"
}

inputs = {
  github_token     = values.github_token
  github_owner     = include.root.locals.github_owner_catalog
  github_repo_name = values.github_repo_name
  # The FEATURE_ prefix is reserved for feature toggles. .github/actions/setup exports only those.
  variables = { for f in values.enabled_features : "FEATURE_${upper(f)}_ENABLED" => "true" }
}
