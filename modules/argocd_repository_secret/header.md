# `argocd_repository_secret` Terraform Module Reference

The [`argocd_repository_secret` module](../argocd_repository_secret/) installs the local [`argocd-repository-secret`](../../charts/argocd-repository-secret/) chart. The chart creates an ArgoCD [repository Secret](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories) that authenticates to a private Git repository over [SSH](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#ssh-repositories). The module reads the private key from the `ssh_private_key` key of a JSON [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) secret.

With `enabled = false`, it creates nothing.
