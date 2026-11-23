include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path   = find_in_parent_folders("provider_k8s_base.hcl")
  expose = true
}

include "provider_helm" {
  path   = find_in_parent_folders("provider_helm.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/argocd_app_of_apps/?ref=${values.version}"
}

# The core argocd_app_of_apps dependency comes from stacks/gpu's autoinclude.

locals {
  repo_url = include.root.locals.github_locals.app_of_apps_repo_url
}

# The DaemonSets only run on GPU nodes, so the NodePools must exist first.
dependency "node_pool_spot" {
  config_path  = "../node_pool_spot"
  skip_outputs = true
}

dependency "node_pool_on_demand" {
  config_path  = "../node_pool_on_demand"
  skip_outputs = true
}

inputs = {
  # cluster_name comes from provider_k8s_base.hcl.
  repo_url              = local.repo_url
  name                  = "app-of-apps-gpu"
  namespace             = "argocd"
  path                  = "apps/features/gpu"
  target_revision       = values.target_revision
  project               = "default"
  destination_namespace = "argocd"
  destination_server    = "https://kubernetes.default.svc"
  # Deleting the root Application cascades to its child Applications.
  finalizers         = ["resources-finalizer.argocd.argoproj.io"]
  sync_options       = ["CreateNamespace=true"]
  prune              = true
  helm_chart_version = values.helm_chart_version
  # Retries span longer than the wait Job's wait_timeout.
  retry = {
    limit = 20
    backoff = {
      duration     = "5s"
      factor       = 2
      max_duration = "2m"
    }
  }
  node_selector = values.wait_job_node_selector
  tolerations   = values.wait_job_tolerations
  helm_values = {
    config = {
      spec = {
        source = {
          repoURL        = local.repo_url
          targetRevision = values.target_revision
        }
      }
    }
    global = {
      environment = include.root.locals.environment_alias
    }
  }
}
