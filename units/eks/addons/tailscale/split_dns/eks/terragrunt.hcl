include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/tailscale_split_dns?ref=${values.version}"
}

dependency "vpc" {
  config_path = "../../../../../vpc/vpc"
  mock_outputs = {
    vpc_cidr_block = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "eks_cluster" {
  config_path = "../../../../cluster"
  mock_outputs = {
    cluster_endpoint = "https://mock.eks.amazonaws.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  domain      = trimprefix(dependency.eks_cluster.outputs.cluster_endpoint, "https://")
  nameservers = [cidrhost(dependency.vpc.outputs.vpc_cidr_block, 2)]
}
