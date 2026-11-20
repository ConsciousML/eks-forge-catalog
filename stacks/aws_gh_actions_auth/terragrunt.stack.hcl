unit "github_oidc_provider" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/github/oidc_provider?ref=${values.version}"
  path   = "github/oidc_provider"

  values = {
    version         = values.version
    url             = values.oidc_url
    client_id_list  = values.oidc_client_id_list
    thumbprint_list = values.oidc_thumbprint_list
    create          = values.create_oidc_provider
  }
}

unit "deploy_key" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/github/deploy_key?ref=${values.version}"
  path   = "github/deploy_key"

  values = {
    version            = values.version
    github_token       = values.github_token
    repositories       = values.deploy_key_repositories
    current_repository = values.github_repo_name
    secret_names       = values.deploy_key_secret_names
    deploy_key_title   = values.deploy_key_title
    read_only          = true
  }
}
