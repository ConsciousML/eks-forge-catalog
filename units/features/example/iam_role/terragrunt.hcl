include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/iam_pod_identity/?ref=${values.version}"
}

# The cluster dependency, for ordering only, comes from stacks/example's autoinclude.

locals {
  cluster_name_full = read_terragrunt_config(find_in_parent_folders("cluster_name_env.hcl")).locals.cluster_name_full
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    s3_bucket_arn = "arn:aws:s3:::mock-example"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name    = local.cluster_name_full
  iam_policy_name = "${include.root.locals.environment}-example-policy"
  iam_role_name   = "${include.root.locals.environment}-example"
  namespace       = "example"   # must match the app-of-apps repo's manifests/features/example/namespaces
  service_account = "s3-lister" # must match the app-of-apps repo's charts/features/example/s3-lister ServiceAccount

  iam_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [dependency.s3.outputs.s3_bucket_arn]
      },
    ]
  })

  tags = values.tags
}
