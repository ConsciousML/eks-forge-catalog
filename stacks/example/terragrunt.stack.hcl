unit "s3" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/example/s3?ref=${values.version}"
  path   = "s3"

  values = {
    version       = values.version_s3
    tags          = {}
    force_destroy = values.force_destroy
  }
}

unit "iam_role" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/example/iam_role?ref=${values.version}"
  path   = "iam_role"

  values = {
    version = values.version
    tags    = {}
  }

  # Applies after the cluster, destroys before it.
  autoinclude {
    dependency "cluster" {
      config_path  = values.cluster_path
      skip_outputs = true
    }
  }
}

unit "app_of_apps" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/example/app_of_apps?ref=${values.version}"
  path   = "app_of_apps"

  values = {
    version            = values.version
    target_revision    = values.app_of_apps_target_revision
    helm_chart_version = values.helm_chart_version
    node_selector      = values.node_selector
    tolerations        = values.tolerations
  }

  # Applies once core's root app is Healthy.
  autoinclude {
    dependency "core_app_of_apps" {
      config_path  = values.app_of_apps_path
      skip_outputs = true
    }
  }
}
