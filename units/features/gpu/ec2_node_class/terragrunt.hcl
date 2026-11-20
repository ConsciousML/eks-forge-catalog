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

# The core karpenter_iam and karpenter_helm dependencies come from stacks/gpu's autoinclude.

inputs = {
  # cluster_name comes from provider_k8s_base.hcl.
  name = "${values.name}-ec2-node-class"
  # Bundled locally alongside modules/helm_release, travels with the same git fetch.
  chart            = "../../charts/karpenter-ec2-node-class"
  namespace        = "kube-system"
  create_namespace = false
  # Karpenter's uninstall waits for every node of this class to be deprovisioned.
  timeout = 600
  helm_values = {
    name                = "${values.name}-ec2-node-class"
    nodeRole            = dependency.karpenter_iam.outputs.node_iam_role_name
    clusterName         = include.provider_k8s_base.locals.cluster_name_full
    amiAlias            = values.ami_alias
    kubeletMaxPods      = values.kubelet_max_pods
    instanceStorePolicy = values.instance_store_policy
  }
}
