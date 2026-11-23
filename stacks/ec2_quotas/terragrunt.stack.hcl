unit "ec2_ondemand_quota" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/service_quota?ref=${values.version}"
  path   = "ec2_ondemand_quota"

  values = {
    version       = values.version
    service_code  = "ec2"
    quota_code    = "L-1216C47A" # Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances
    desired_value = values.ondemand_desired_value
  }
}

unit "ec2_spot_quota" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/service_quota?ref=${values.version}"
  path   = "ec2_spot_quota"

  values = {
    version       = values.version
    service_code  = "ec2"
    quota_code    = "L-34B43A08" # All Standard (A, C, D, H, I, M, R, T, Z) Spot Instance Requests
    desired_value = values.spot_desired_value
  }
}

unit "ec2_gpu_spot_quota" {
  enabled = values.gpu_spot_desired_value > 0
  source  = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/service_quota?ref=${values.version}"
  path    = "ec2_gpu_spot_quota"

  values = {
    version       = values.version
    service_code  = "ec2"
    quota_code    = "L-3819A6DF" # All G and VT Spot Instance Requests
    desired_value = values.gpu_spot_desired_value
  }
}

unit "ec2_gpu_ondemand_quota" {
  enabled = values.gpu_ondemand_desired_value > 0
  source  = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/service_quota?ref=${values.version}"
  path    = "ec2_gpu_ondemand_quota"

  values = {
    version       = values.version
    service_code  = "ec2"
    quota_code    = "L-DB2E81BA" # Running On-Demand G and VT instances
    desired_value = values.gpu_ondemand_desired_value
  }
}
