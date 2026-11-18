<!-- BEGIN_TF_DOCS -->
# `argocd_app_of_apps` Terraform Module Reference

The [`argocd_app_of_apps` module](../argocd\_app\_of\_apps/) installs the [`argocd-apps`](https://github.com/argoproj/argo-helm/tree/main/charts/argocd-apps) Helm chart to create the root ArgoCD [`Application`](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) of the [app-of-apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern). ArgoCD syncs this Application, which deploys every child Application found under the configured repository path.

A second release, of the [`argocd-app-of-apps-wait`](../../charts/argocd-app-of-apps-wait/) chart, runs a post-install and post-upgrade hook Job. The Job refreshes the root Application and each child Application, then waits until all of them are Synced and Healthy. The apply fails when an Application isn't Synced and Healthy within `wait_timeout`. A failed Job stays in the namespace, and `kubectl logs job/<name>-wait -n <namespace>` names the Application and its status.

The Job runs again only when the root Application's values change. A change made only in the app of apps repository isn't waited on.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.wait](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster, used to configure the Kubernetes provider | `string` | n/a | yes |
| <a name="input_destination_namespace"></a> [destination\_namespace](#input\_destination\_namespace) | Kubernetes namespace ArgoCD will deploy child applications into | `string` | `"argocd"` | no |
| <a name="input_destination_server"></a> [destination\_server](#input\_destination\_server) | Kubernetes API server URL of the destination cluster | `string` | `"https://kubernetes.default.svc"` | no |
| <a name="input_finalizers"></a> [finalizers](#input\_finalizers) | List of finalizers applied to the Application resource | `list(string)` | <pre>[<br/>  "resources-finalizer.argocd.argoproj.io"<br/>]</pre> | no |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | Version of the argo-helm/argocd-apps chart to install | `string` | n/a | yes |
| <a name="input_helm_values"></a> [helm\_values](#input\_helm\_values) | Helm values injected into spec.source.helm.values on the app-of-apps Application | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ArgoCD Application resource | `string` | `"app-of-apps"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where the ArgoCD Application resource is created | `string` | `"argocd"` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Node selector of the wait Job's pod | `map(string)` | `{}` | no |
| <a name="input_path"></a> [path](#input\_path) | Path within the repository containing the application manifests | `string` | `"apps"` | no |
| <a name="input_project"></a> [project](#input\_project) | ArgoCD project the Application belongs to | `string` | `"default"` | no |
| <a name="input_prune"></a> [prune](#input\_prune) | Whether ArgoCD should delete resources that are no longer tracked | `bool` | `true` | no |
| <a name="input_repo_url"></a> [repo\_url](#input\_repo\_url) | Git repository URL that ArgoCD will sync from | `string` | n/a | yes |
| <a name="input_retry"></a> [retry](#input\_retry) | Retry policy for the app-of-apps Application's sync operation. Defaults raised above ArgoCD's own defaults (limit 5, maxDuration 3m) so slow-starting sync waves (e.g. a component's first rollout) have enough runway to go Healthy before the sync gives up. | <pre>object({<br/>    limit = number<br/>    backoff = object({<br/>      duration     = string<br/>      factor       = number<br/>      max_duration = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "backoff": {<br/>    "duration": "5s",<br/>    "factor": 2,<br/>    "max_duration": "2m"<br/>  },<br/>  "limit": 7<br/>}</pre> | no |
| <a name="input_sync_options"></a> [sync\_options](#input\_sync\_options) | List of ArgoCD sync options | `list(string)` | <pre>[<br/>  "CreateNamespace=true"<br/>]</pre> | no |
| <a name="input_target_revision"></a> [target\_revision](#input\_target\_revision) | Git branch, tag, or commit SHA to sync | `string` | `"main"` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | Tolerations of the wait Job's pod | `list(any)` | `[]` | no |
| <a name="input_wait_timeout"></a> [wait\_timeout](#input\_wait\_timeout) | Seconds the apply waits for the root Application and its child Applications to be Synced and Healthy before failing | `number` | `1800` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->