unit "iam_role_github_actions" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/github/iam_role?ref=${values.version}"
  path   = "github/iam_role"

  values = {
    version              = values.version
    name                 = values.iam_role_name
    github_owner         = values.github_owner
    github_repo_name     = values.github_repo_name
    github_branch        = values.github_branch
    subject_claim_prefix = try(values.subject_claim_prefix, null)
    inline_policies      = try(values.inline_policies, [])
    read_only            = try(values.read_only, false)
    plan_secret_names    = try(values.plan_secret_names, [])
    max_session_duration = try(values.max_session_duration, 3600)
  }
}

unit "iam_policies" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/github/iam_policies?ref=${values.version}"
  path   = "github/iam_policies"

  values = {
    version     = values.version
    policy_arns = try(values.policy_arns, [])
    read_only   = try(values.read_only, false)
  }
}

unit "github_secrets" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/github/secrets/action?ref=${values.version}"
  path   = "github/secrets/action"

  values = {
    version              = values.version
    github_token         = values.github_token
    github_owner         = values.github_owner
    github_repo_name     = values.github_repo_name
    role_arn_secret_name = try(values.role_arn_secret_name, "AWS_ROLE_ARN")
  }
}
