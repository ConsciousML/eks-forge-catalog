include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/aws_secretsmanager_secret/?ref=${values.version}"
}

dependency "service" {
  config_path = "../service"

  mock_outputs = {
    integration_key = "mock-integration-key"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  # Name must match the alertmanager-pagerduty-secrets remoteKey in
  # units/eks/addons/argocd/app_of_apps/terragrunt.hcl.
  name = "${values.environment}-alertmanager-pagerduty"
  # Key (routing_key) must match remoteProperty in
  # charts/external-secrets-operator/secret-sync/alertmanager-pagerduty-secrets-values.yaml (eks-forge-app-of-apps repo).
  secret_data = {
    routing_key = dependency.service.outputs.integration_key
  }
  recovery_window_in_days = 0
}
