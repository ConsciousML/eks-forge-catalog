<!-- BEGIN_TF_DOCS -->
# `argocd_repository_secret` Terraform Module Reference

The [`argocd_repository_secret` module](../argocd\_repository\_secret/) installs the local [`argocd-repository-secret`](../../charts/argocd-repository-secret/) chart. The chart creates an ArgoCD [repository Secret](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories) that authenticates to a private Git repository over [SSH](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#ssh-repositories). The module reads the private key from the `ssh_private_key` key of a JSON [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) secret.

With `enabled = false`, it creates nothing.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 6.55.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 6.55.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/6.55.0/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster, used to configure the Helm provider | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the repository Secret. Public repositories need none | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Helm release and of the ArgoCD repository Secret | `string` | `"argocd-repository-secret"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where ArgoCD runs | `string` | `"argocd"` | no |
| <a name="input_repo_url"></a> [repo\_url](#input\_repo\_url) | Repository URL. Must match the Application repoURL exactly | `string` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name of the Secrets Manager secret holding the SSH private key under the ssh\_private\_key JSON key | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->