locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  github_token = get_env("GITHUB_TOKEN")

  aws_region = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.region
  account_id = get_aws_account_id()
  # State buckets the CI init and plan read (pipelines/root.hcl). CI, bootstrap, and dev pipelines under pipelines/bootstrap.
  ci_state_buckets = [
    for env in ["catalog-eks-ci", "bootstrap-catalog-eks", "dev"] : "tofu-state-${local.account_id}-${local.aws_region}-${env}"
  ]
  lock_table_arn      = "arn:aws:dynamodb:${local.aws_region}:${local.account_id}:table/terragrunt_lock_table"
  state_kms_key_alias = "alias/${read_terragrunt_config(find_in_parent_folders("bootstrap/environment.hcl")).locals.environment}-tofu-state"

  # GitHub's `sub` prefix for the repository. Holds owner and repo IDs with immutable subject claims.
  subject_claim_prefix = run_cmd("--terragrunt-quiet", "gh", "api", "repos/${local.github_owner_catalog}/${local.github_repo_name_catalog}/actions/oidc/customization/sub", "--jq", ".sub_claim_prefix // error(\"sub_claim_prefix missing from GitHub API response\")")
}

stack "aws_gh_actions_auth" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//stacks/aws_gh_actions_auth?ref=${local.version}"
  path   = "github_actions_bootstrap"
  values = {
    version                  = local.version
    github_owner_catalog     = local.github_owner_catalog
    github_repo_name_catalog = local.github_repo_name_catalog
    github_owner             = local.github_owner_catalog
    github_repo_name         = local.github_repo_name_catalog
    subject_claim_prefix     = local.subject_claim_prefix
    github_token             = local.github_token
    iam_role_name            = "gh-terragrunt-role-catalog"
    # Read-only, CI only plans.
    policy_arns = [
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
    ]
    inline_policies = [
      {
        name = "TerragruntPlan"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Sid      = "StateLock"
              Effect   = "Allow"
              Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
              Resource = local.lock_table_arn
            },
            {
              Sid      = "StateEncryption"
              Effect   = "Allow"
              Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
              Resource = "*"
              Condition = {
                "ForAnyValue:StringEquals" = { "kms:ResourceAliases" = local.state_kms_key_alias }
              }
            },
            {
              Sid      = "ArgoCDRepositorySecret"
              Effect   = "Allow"
              Action   = "secretsmanager:GetSecretValue"
              Resource = "arn:aws:secretsmanager:${local.aws_region}:${local.account_id}:secret:${local.github_locals.app_of_apps_deploy_key_secret_name}-*"
            },
            {
              Sid         = "DenyS3ReadsOutsideCIStateBuckets"
              Effect      = "Deny"
              Action      = "s3:GetObject"
              NotResource = [for b in local.ci_state_buckets : "arn:aws:s3:::${b}/*"]
            },
            {
              Sid         = "DenySSMReadsOutsideAWSPublic"
              Effect      = "Deny"
              Action      = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath", "ssm:GetParameterHistory"]
              NotResource = "arn:aws:ssm:*::parameter/aws/*"
            },
            {
              Sid         = "DenyDynamoDBReadsOutsideLockTable"
              Effect      = "Deny"
              Action      = ["dynamodb:GetItem", "dynamodb:BatchGetItem", "dynamodb:Query", "dynamodb:Scan"]
              NotResource = local.lock_table_arn
            },
          ]
        })
      }
    ]
    github_branch           = "*"
    oidc_url                = "https://token.actions.githubusercontent.com"
    oidc_client_id_list     = ["sts.amazonaws.com"]
    oidc_thumbprint_list    = []
    create_oidc_provider    = true
    deploy_key_repositories = [local.github_repo_name_catalog]
    deploy_key_secret_names = ["DEPLOY_KEY_TG_CATALOG"]
    deploy_key_title        = "Terragrunt Catalog Deploy Key"
  }
}

unit "deploy_key_terraform_docs" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//units/github/deploy_key/?ref=${local.version}"
  path   = "github/deploy_key"

  values = {
    version            = local.version
    github_token       = local.github_token
    repositories       = [local.github_repo_name_catalog]
    current_repository = local.github_repo_name_catalog
    secret_names       = ["TERRAFORM_DOCS_DEPLOY_KEY"]
    deploy_key_title   = "Terraform Docs Deploy Key"
    read_only          = false
  }
}
