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
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/helm_release/?ref=${values.version}"
}

dependency "ec2_node_class" {
  config_path = "../ec2_node_class"
  mock_outputs = {
    name = "mock-gpu"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  # cluster_name comes from provider_k8s_base.hcl.
  name = values.name
  # Bundled locally alongside modules/helm_release, travels with the same git fetch.
  chart            = "../../charts/karpenter-node-pool"
  namespace        = "kube-system"
  create_namespace = false
  helm_values = {
    name = values.name
    # helm_release's "name" output is the EC2NodeClass's metadata.name.
    ec2NodeClassName       = dependency.ec2_node_class.outputs.name
    requirements           = values.requirements
    taints                 = values.taints
    startupTaints          = values.startup_taints
    limitsCpu              = values.limits_cpu
    terminationGracePeriod = try(values.termination_grace_period, null)
    expireAfter            = try(values.expire_after, null)
    disruption             = values.disruption
  }
}
