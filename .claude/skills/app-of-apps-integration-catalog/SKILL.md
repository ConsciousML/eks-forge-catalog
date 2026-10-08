---
name: app-of-apps-integration-catalog
description: Pass a Terraform-sourced value (IAM role, Pod Identity, secret name, ACM ARN, region, ...) to an app in eks-forge-app-of-apps through `appParams`. Use before editing `appParams` or a `dependency` block in units/eks/addons/argocd/app_of_apps, and when adding or editing an app that needs a value only this repo's Terraform can produce.
---

Follow
[Pass Terraform Values to an App](https://eks-forge.readthedocs.io/latest/docs/applications/pass-terraform-values-to-an-app/)
for the steps (dependency block on `argocd_app_of_apps`, `appParams` entry, deploy).
