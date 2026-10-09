locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  # Tailscale tag assigned to CI runner devices joining via WIF
  # Must already be defined as a tagOwner in the ACL applied by the sibling `acl` pipeline
  ci_tag = "tag:ci"

  # GitHub's `sub` prefix for the repository. Holds owner and repo IDs with immutable subject claims.
  subject_claim_prefix = run_cmd("--terragrunt-quiet", "gh", "api", "repos/${local.github_owner_catalog}/${local.github_repo_name_catalog}/actions/oidc/customization/sub", "--jq", ".sub_claim_prefix // error(\"sub_claim_prefix missing from GitHub API response\")")
}

stack "tailscale_wif" {
  source = "github.com/${local.github_owner_catalog}/${local.github_repo_name_catalog}//stacks/tailscale_wif?ref=${local.version}"
  path   = "tailscale_wif"

  values = {
    version                  = local.version
    github_owner_catalog     = local.github_owner_catalog
    github_repo_name_catalog = local.github_repo_name_catalog
    github_owner             = local.github_owner_catalog
    github_repo_name         = local.github_repo_name_catalog
    subject_claim_prefix     = local.subject_claim_prefix
    github_token             = get_env("GITHUB_TOKEN")
    issuer                   = "https://token.actions.githubusercontent.com"
    scopes                   = ["all"]
    ci_tag                   = local.ci_tag
  }
}
