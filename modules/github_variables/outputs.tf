output "variables_created" {
  description = "List of GitHub variables that were created"
  value       = [for k, v in github_actions_variable.this : v.variable_name]
}
