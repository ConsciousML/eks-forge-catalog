unit "ec2_node_class" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/gpu/ec2_node_class?ref=${values.version}"
  path   = "ec2_node_class"

  values = {
    version               = values.version
    name                  = values.name
    ami_alias             = values.ec2_node_class_ami_alias
    kubelet_max_pods      = values.ec2_node_class_kubelet_max_pods
    instance_store_policy = values.ec2_node_class_instance_store_policy
  }

  # Applies after Karpenter's CRDs and node role, destroys before them.
  autoinclude {
    dependency "karpenter_iam" {
      config_path = values.core_karpenter_iam_path
      mock_outputs = {
        node_iam_role_name = "mock-node-role"
      }
      mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
    }

    dependency "karpenter_helm" {
      config_path  = values.core_karpenter_helm_path
      skip_outputs = true
    }
  }
}

unit "node_pool_spot" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/gpu/node_pool?ref=${values.version}"
  path   = "node_pool_spot"

  values = {
    version = values.version
    name    = "${values.name}-spot"
    requirements = concat(
      [{ key = "karpenter.sh/capacity-type", operator = "In", values = ["spot"] }],
      values.node_pool_requirements,
    )
    taints                   = values.node_pool_taints
    startup_taints           = values.node_pool_startup_taints
    limits_cpu               = values.node_pool_spot_limits_cpu
    termination_grace_period = values.node_pool_termination_grace_period
    expire_after             = values.node_pool_expire_after
    disruption               = values.node_pool_disruption
  }
}

unit "node_pool_on_demand" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/gpu/node_pool?ref=${values.version}"
  path   = "node_pool_on_demand"

  values = {
    version = values.version
    name    = "${values.name}-on-demand"
    requirements = concat(
      [{ key = "karpenter.sh/capacity-type", operator = "In", values = ["on-demand"] }],
      values.node_pool_requirements,
    )
    taints                   = values.node_pool_taints
    startup_taints           = values.node_pool_startup_taints
    limits_cpu               = values.node_pool_on_demand_limits_cpu
    termination_grace_period = values.node_pool_termination_grace_period
    expire_after             = values.node_pool_expire_after
    disruption               = values.node_pool_disruption
  }
}

unit "app_of_apps" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/features/gpu/app_of_apps?ref=${values.version}"
  path   = "app_of_apps"

  values = {
    version                = values.version
    target_revision        = values.app_of_apps_target_revision
    helm_chart_version     = values.app_of_apps_helm_chart_version
    wait_job_node_selector = values.app_of_apps_wait_job_node_selector
    wait_job_tolerations   = values.app_of_apps_wait_job_tolerations
  }

  # Applies once core's root app is Healthy.
  autoinclude {
    dependency "core_app_of_apps" {
      config_path  = values.core_app_of_apps_path
      skip_outputs = true
    }
  }
}
