data "aws_secretsmanager_secret_version" "this" {
  count = var.enabled ? 1 : 0

  secret_id = var.secret_name
}

resource "helm_release" "this" {
  count = var.enabled ? 1 : 0

  name             = var.name
  chart            = "${path.module}/../../charts/argocd-repository-secret"
  namespace        = var.namespace
  create_namespace = false

  # Sensitive through secret_string, so the key stays out of plan output.
  values = [yamlencode({
    name          = var.name
    url           = var.repo_url
    sshPrivateKey = jsondecode(data.aws_secretsmanager_secret_version.this[0].secret_string).ssh_private_key
  })]
}
