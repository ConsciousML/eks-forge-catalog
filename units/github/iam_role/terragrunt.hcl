include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment
  root        = include.root.locals
  account_id  = get_aws_account_id()
  read_only   = try(values.read_only, false)

  # Plan-only access on top of ReadOnlyAccess (see iam_policies). Catalog state key only, so other repos' state stays unreadable.
  plan_policy = {
    name = "TerragruntPlan"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = concat([
        {
          Sid      = "StateLock"
          Effect   = "Allow"
          Action   = ["dynamodb:PutItem", "dynamodb:DeleteItem"]
          Resource = "arn:aws:dynamodb:${local.root.aws_region}:${local.account_id}:table/${local.root.backend_config.dynamodb_table}"
        },
        {
          Sid       = "StateEncryption"
          Effect    = "Allow"
          Action    = ["kms:Decrypt", "kms:GenerateDataKey"]
          Resource  = "*"
          Condition = { "ForAnyValue:StringEquals" = { "kms:ResourceAliases" = local.root.state_kms_key_alias } }
        },
        ], length(try(values.plan_secret_names, [])) == 0 ? [] : [
        {
          Sid      = "PlanSecrets"
          Effect   = "Allow"
          Action   = "secretsmanager:GetSecretValue"
          Resource = [for n in values.plan_secret_names : "arn:aws:secretsmanager:${local.root.aws_region}:${local.account_id}:secret:${n}-*"]
        },
      ])
    })
  }
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/iam_role_github_actions?ref=${values.version}"
}

inputs = {
  name                 = "${local.environment}-${values.name}"
  github_owner         = values.github_owner
  github_repo_name     = values.github_repo_name
  github_branch        = values.github_branch
  subject_claim_prefix = try(values.subject_claim_prefix, null)
  inline_policies      = concat(try(values.inline_policies, []), local.read_only ? [local.plan_policy] : [])
  max_session_duration = try(values.max_session_duration, 3600)
  tags = {
    environment = "${local.environment}"
  }
}
