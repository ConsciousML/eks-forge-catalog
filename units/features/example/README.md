# Example Feature

Provisions the AWS side of the `example` optional feature, a minimal feature proving the optional feature mechanism end to end. A pod lists an S3 bucket through Pod Identity.

The [`example` stack](../../../stacks/example/) groups these units. An environment's stack file declares it as a `stack` block, enabled by [`EXAMPLE_ENABLED`](../../../docs/environment-variables.md#example_enabled).

## Concepts

- [Terragrunt Stacks](https://docs.terragrunt.com/features/stacks/)
- [`autoinclude`](https://docs.terragrunt.com/reference/hcl/blocks/autoinclude/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[s3](s3/)**: the S3 bucket the pod lists
- **[iam_role](iam_role/)**: an IAM role bound to the `s3-lister` service account in the `example` namespace via Pod Identity, scoped to `s3:ListBucket` on the bucket
- **[app_of_apps](app_of_apps/)**: the `example-apps` root `Application`, syncing `apps/features/example` from the same app-of-apps revision as core. Its `appParams` carry the bucket name and region. It applies after every other unit of the feature and destroys before them. Its finalizer deletes the child apps, and so the `example` namespace
- **[`example-namespaces`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/manifests/features/example/namespaces)** (app-of-apps): the `example` namespace. Not deployed by these units
- **[`example-s3-lister`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/charts/features/example/s3-lister)** (app-of-apps): the pod listing the bucket, and its S3 egress policy. Not deployed by these units

## Upstream Dependencies

- **[`cluster`](../../eks/cluster/)** (core): `iam_role` creates its Pod Identity association on the cluster. The stack's `autoinclude` declares the dependency, from the `cluster_path` value
- **[`argocd/app_of_apps`](../../eks/addons/argocd/app_of_apps/)** (core): `app_of_apps` applies once core's root app is Synced and Healthy. The stack's `autoinclude` declares the dependency, from the `app_of_apps_path` value
