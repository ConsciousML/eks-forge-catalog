locals {
  # Load AWS region variable
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Load environment related variables (dev, staging, prod, ...)
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  aws_region        = local.region_vars.locals.region
  environment       = local.environment_vars.locals.environment
  environment_alias = local.environment_vars.locals.environment_alias

  github_locals                = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog         = local.github_locals.github_owner_catalog
  github_owner_app_of_apps     = local.github_locals.github_owner_app_of_apps
  github_repo_name_catalog     = local.github_locals.github_repo_name_catalog
  github_repo_name_app_of_apps = local.github_locals.github_repo_name_app_of_apps

  # Must match the alias of pipelines/bootstrap/state_encryption, whose own state stays unencrypted.
  bootstrap_environment = read_terragrunt_config("${get_parent_terragrunt_dir()}/bootstrap/environment.hcl").locals.environment
  state_kms_key_alias   = "alias/${local.bootstrap_environment}-tofu-state"
  state_kms_key_arn     = "arn:aws:kms:${local.aws_region}:${get_aws_account_id()}:${local.state_kms_key_alias}"
  state_encryption      = !strcontains(get_terragrunt_dir(), "state_kms_key")
}

# Configure AWS backend for storing Terraform state files
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = merge({
    region = "${local.aws_region}"

    # The bucket name is suffixed using the env name (i.e `dev`, `staging`, ect.)
    # This allows to completely isolate states between environments
    bucket = "tofu-state-${get_aws_account_id()}-${local.aws_region}-${local.environment}"

    # The state file path within the bucket, based on module's relative path to ensure each module has its own isolated state
    key            = "${path_relative_to_include()}/tofu.tfstate"
    dynamodb_table = "terragrunt_lock_table"
    }, local.state_encryption ? {
    encrypt               = true
    kms_key_id            = local.state_kms_key_arn
    bucket_sse_algorithm  = "aws:kms"
    bucket_sse_kms_key_id = local.state_kms_key_arn
  } : {})

  # Client side state and plan encryption, so S3 and .terragrunt-cache only hold ciphertext.
  encryption = local.state_encryption ? {
    key_provider = "aws_kms"
    kms_key_id   = local.state_kms_key_alias
    region       = local.aws_region
    key_spec     = "AES_256"
  } : null
}

generate "provider" {
  path      = "providers_aws.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

catalog {
  urls = [
    "git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git"
  ]
}

# Pass key variables to child configurations
inputs = merge(
  local.region_vars.locals,
  local.environment_vars.locals
)