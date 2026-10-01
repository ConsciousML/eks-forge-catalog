# `argocd_app_of_apps` Terraform Module Reference

The [`argocd_app_of_apps` module](../argocd_app_of_apps/) installs the [`argocd-apps`](https://github.com/argoproj/argo-helm/tree/main/charts/argocd-apps) Helm chart to create the root ArgoCD [`Application`](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) of the [app-of-apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern). ArgoCD syncs this Application, which deploys every child Application found under the configured repository path.
