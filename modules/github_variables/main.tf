resource "github_actions_variable" "this" {
  for_each = var.variables

  repository    = var.github_repo_name
  variable_name = each.key
  value         = each.value
}
