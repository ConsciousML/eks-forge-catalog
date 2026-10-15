# `argocd_repository` Terraform Module Reference

The [`argocd_repository` module](../argocd_repository/) creates an ArgoCD [repository Secret](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories) that authenticates to a private Git repository over SSH. It reads the private key from the `ssh_private_key` key of a JSON [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) secret.

With `enabled = false`, it creates nothing.
