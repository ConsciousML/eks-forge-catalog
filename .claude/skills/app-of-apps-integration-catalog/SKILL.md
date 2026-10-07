---
name: app-of-apps-integration-catalog
description: Thread a Terraform-sourced value (IAM, Pod Identity, Secrets Manager, ACM, ...) into an app-of-apps Helm value, or add a new app to app-of-apps. Use when an app in argocd-app-of-apps-template needs a value only this repo's Terraform can produce.
---

Follow
[Pass Terraform Values to an App](https://eks-forge.readthedocs.io/latest/docs/applications/pass-terraform-values-to-an-app/)
for the steps (dependency block on `argocd_app_of_apps`, `appParams` entry, deploy).
