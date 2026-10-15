data "aws_secretsmanager_secret_version" "this" {
  count = var.enabled ? 1 : 0

  secret_id = var.secret_name
}

resource "kubernetes_secret_v1" "this" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = var.repo_url
    sshPrivateKey = jsondecode(data.aws_secretsmanager_secret_version.this[0].secret_string).ssh_private_key
  }
}
