# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Helm provider"
  type        = string
}

variable "enabled" {
  description = "Whether to create the repository Secret. Public repositories need none"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the Helm release and of the ArgoCD repository Secret"
  type        = string
  default     = "argocd-repository-secret"
}

variable "namespace" {
  description = "Namespace where ArgoCD runs"
  type        = string
  default     = "argocd"
}

variable "repo_url" {
  description = "Repository URL. Must match the Application repoURL exactly"
  type        = string
}

variable "secret_name" {
  description = "Name of the Secrets Manager secret holding the SSH private key under the ssh_private_key JSON key"
  type        = string
}
