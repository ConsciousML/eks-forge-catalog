locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  # Edit before deploying. See README.md for how to check current quota values and headroom.
  ondemand_desired_value = 32
  spot_desired_value     = 32
  # G and VT Spot quota, 0 by default. Requested only when the gpu feature is enabled.
  gpu_spot_desired_value = get_env("FEATURE_GPU_ENABLED", "false") == "true" ? 16 : 0
}

stack "ec2_quotas" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//stacks/ec2_quotas?ref=${local.version}"
  path   = "ec2_quotas"
  values = {
    version                  = local.version
    github_owner_catalog     = local.github_owner_catalog
    github_repo_name_catalog = local.github_repo_name_catalog

    ondemand_desired_value = local.ondemand_desired_value
    spot_desired_value     = local.spot_desired_value
    gpu_spot_desired_value = local.gpu_spot_desired_value
  }
}
