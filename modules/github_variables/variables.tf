variable "github_token" {
  description = "GitHub personal access token with 'repo' permissions. Required to create and manage GitHub Actions variables"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub organization or user account that owns the target repository"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name where variables will be stored"
  type        = string
}

variable "variables" {
  description = "Map of GitHub Actions variable names to their values"
  type        = map(string)
}
