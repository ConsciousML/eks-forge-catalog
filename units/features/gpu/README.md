# GPU Feature

Provisions the AWS side of the `gpu` optional feature: Karpenter GPU nodes on the EKS-optimized AL2023 NVIDIA AMI, which ships the NVIDIA driver and container toolkit. A pod requesting `nvidia.com/gpu` brings up a single-GPU spot node, and Karpenter consolidates it away once empty.

The [`gpu` stack](../../../stacks/gpu/) groups these units. An environment's stack file declares it as a `stack` block, enabled by [`FEATURE_GPU_ENABLED`](../../../docs/environment-variables.md#feature_gpu_enabled), and sets the NodePool's requirements, taint, and limits.

> **Note**: GPU nodes launch under the account's G and VT Spot vCPU quota (`L-3819A6DF`), 0 by default and separate from the Standard quotas. The [AWS Service Quotas Bootstrap](../../../pipelines/bootstrap/aws_service_quotas/) requests it when `FEATURE_GPU_ENABLED` is `true`. Without it, NodeClaims fail and GPU pods stay `Pending`.

## Concepts

- [EKS-optimized accelerated AMIs](https://docs.aws.amazon.com/eks/latest/userguide/ml-eks-optimized-ami.html)
- [NVIDIA device plugin](https://github.com/NVIDIA/k8s-device-plugin)
- [DCGM exporter](https://github.com/NVIDIA/dcgm-exporter)
- [Karpenter NodePool](https://karpenter.sh/docs/concepts/nodepools/)
- [Karpenter `instanceStorePolicy`](https://karpenter.sh/docs/concepts/nodeclasses/#specinstancestorepolicy)

## What's Inside

- **[ec2_node_class](ec2_node_class/)**: the `gpu` `EC2NodeClass`, via the chart bundled under [`charts/karpenter-ec2-node-class`](../../../charts/karpenter-ec2-node-class/). `instanceStorePolicy: RAID0` puts kubelet, containerd images, and `emptyDir` on the instance's local NVMe. The root EBS volume keeps the AMI's size
- **[node_pool](node_pool/)**: the `gpu` `NodePool`, via the chart bundled under [`charts/karpenter-node-pool`](../../../charts/karpenter-node-pool/). It carries the `karpenter.sh/workload-class=gpu:NoSchedule` taint and Cilium's startup taint
- **[app_of_apps](app_of_apps/)**: the `gpu-apps` root `Application`, syncing `apps/features/gpu` from the same app-of-apps revision as core. It applies after every other unit of the feature and destroys before them. Its finalizer deletes the child apps, and so the `gpu` namespace
- **[`gpu-namespaces`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/manifests/features/gpu/namespaces)** (app-of-apps): the `gpu` namespace. Not deployed by these units
- **[`gpu-nvidia-device-plugin`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/charts/features/gpu/nvidia-device-plugin)** (app-of-apps): the DaemonSet advertising `nvidia.com/gpu` on GPU nodes. Not deployed by these units
- **[`gpu-dcgm-exporter`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/charts/features/gpu/dcgm-exporter)** (app-of-apps): the DaemonSet exporting GPU metrics to Prometheus, and the **GPU** Grafana dashboard. Not deployed by these units

## Scheduling a Pod on a GPU Node

A pod needs the taint's toleration and a `nvidia.com/gpu` limit. Kubernetes has no GPU memory resource, so a minimum GPU memory is a node affinity on `karpenter.k8s.aws/instance-gpu-memory`, in MiB. Karpenter picks the cheapest allowed instance type matching it and the pod's CPU and memory requests.

```yaml
spec:
  tolerations:
    - key: karpenter.sh/workload-class
      value: gpu
      effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: karpenter.k8s.aws/instance-gpu-memory
                operator: Gt
                values: ["20479"]
  containers:
    - name: model
      resources:
        limits:
          nvidia.com/gpu: 1
```

GPU memory per family in the stack's allowlist, as Karpenter labels it:

| Family | GPU | `instance-gpu-memory` (MiB) | CUDA compute capability |
|--------|-----|------------------------------|-------------------------|
| `g4dn` | T4 | 16384 | 7.5 |
| `g5` | A10G | 22888 | 8.6 |
| `g6`, `gr6` | L4 | 22888 | 8.9 |
| `g7` | RTX PRO 4500 | 32768 | 12.0 |
| `g6e` | L40S | 45776 | 8.9 |
| `g7e` | RTX PRO 6000 | 98304 | 12.0 |

`WhenEmptyOrUnderutilized` consolidation can replace a node running a GPU pod with a cheaper one. A pod annotated `karpenter.sh/do-not-disrupt: "true"` blocks it.

## Upstream Dependencies

- **[`karpenter/iam`](../../eks/addons/karpenter/iam/)** (core): `ec2_node_class` reads the node IAM role name from it. The stack's `autoinclude` declares the dependency, from the `karpenter_iam_path` value
- **[`karpenter/helm`](../../eks/addons/karpenter/helm/)** (core): `ec2_node_class` applies once Karpenter and its CRDs exist. The stack's `autoinclude` declares the dependency, from the `karpenter_helm_path` value
- **[`argocd/app_of_apps`](../../eks/addons/argocd/app_of_apps/)** (core): `app_of_apps` applies once core's root app is Synced and Healthy. The stack's `autoinclude` declares the dependency, from the `app_of_apps_path` value
