unit "ec2_node_class" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/gpu/ec2_node_class?ref=${values.version}"
  path   = "ec2_node_class"

  values = {
    version               = values.version
    name                  = values.name
    ami_alias             = values.ami_alias
    kubelet_max_pods      = values.kubelet_max_pods
    instance_store_policy = values.instance_store_policy
  }

  # Applies after Karpenter's CRDs and node role, destroys before them.
  autoinclude {
    dependency "karpenter_iam" {
      config_path = values.karpenter_iam_path
      mock_outputs = {
        node_iam_role_name = "mock-node-role"
      }
      mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
    }

    dependency "karpenter_helm" {
      config_path  = values.karpenter_helm_path
      skip_outputs = true
    }
  }
}

unit "node_pool" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/gpu/node_pool?ref=${values.version}"
  path   = "node_pool"

  values = {
    version        = values.version
    name           = values.name
    requirements   = values.requirements
    taints         = values.taints
    startup_taints = values.startup_taints
    limits_cpu     = values.limits_cpu
    expire_after   = values.expire_after
    disruption     = values.disruption
  }
}

unit "app_of_apps" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/gpu/app_of_apps?ref=${values.version}"
  path   = "app_of_apps"

  values = {
    version                = values.version
    target_revision        = values.app_of_apps_target_revision
    helm_chart_version     = values.helm_chart_version
    wait_job_node_selector = values.wait_job_node_selector
    wait_job_tolerations   = values.wait_job_tolerations
  }

  # Applies once core's root app is Healthy.
  autoinclude {
    dependency "core_app_of_apps" {
      config_path  = values.app_of_apps_path
      skip_outputs = true
    }
  }
}
