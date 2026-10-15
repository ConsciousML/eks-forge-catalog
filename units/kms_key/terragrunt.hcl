include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/kms_key?ref=${values.version}"
}

inputs = {
  alias_name  = values.alias_name
  description = try(values.description, null)
}
