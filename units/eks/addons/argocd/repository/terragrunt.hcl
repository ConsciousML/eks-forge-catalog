include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path   = find_in_parent_folders("provider_k8s_base.hcl")
  expose = true
}

include "provider_kubernetes" {
  path   = find_in_parent_folders("provider_kubernetes.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/argocd_repository/?ref=${values.version}"
}

# The argocd namespace must exist.
dependency "argocd" {
  config_path  = "../helm"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  enabled      = include.root.locals.app_of_apps_private
  repo_url     = include.root.locals.app_of_apps_repo_url
  # Written by the app_of_apps_deploy_key bootstrap.
  secret_name = include.root.locals.app_of_apps_deploy_key_secret_name
}
