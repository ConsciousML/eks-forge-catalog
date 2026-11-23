# GPU Feature

Provisions the AWS side of the `gpu` optional feature: Karpenter GPU nodes on the EKS-optimized AL2023 NVIDIA AMI, which ships the NVIDIA driver and container toolkit. A pod requesting `nvidia.com/gpu` brings up a single-GPU spot or on-demand node. Karpenter consolidates the node away once empty.

The [`gpu` stack](../../../stacks/gpu/) groups these units. An environment's stack file declares it as a `stack` block, enabled by [`FEATURE_GPU_ENABLED`](../../../docs/environment-variables.md#feature_gpu_enabled), and sets the NodePools' shared requirements and taint, and per-pool limits.

> **Note**: GPU nodes launch under the account's G and VT Spot (`L-3819A6DF`) and On-Demand (`L-DB2E81BA`) vCPU quotas, 0 by default and separate from the Standard quotas. The [AWS Service Quotas Bootstrap](../../../pipelines/bootstrap/aws_service_quotas/) requests both when `FEATURE_GPU_ENABLED` is `true`. Without them, NodeClaims fail and GPU pods stay `Pending`. Each NodePool's CPU limit matches its quota.

## Concepts

- [EKS-optimized accelerated AMIs](https://docs.aws.amazon.com/eks/latest/userguide/ml-eks-optimized-ami.html)
- [NVIDIA device plugin](https://github.com/NVIDIA/k8s-device-plugin)
- [DCGM exporter](https://github.com/NVIDIA/dcgm-exporter)
- [Karpenter NodePool](https://karpenter.sh/docs/concepts/nodepools/)
- [Karpenter `instanceStorePolicy`](https://karpenter.sh/docs/concepts/nodeclasses/#specinstancestorepolicy)

## What's Inside

- **[ec2_node_class](ec2_node_class/)**: the `gpu-ec2-node-class` `EC2NodeClass`, via the chart bundled under [`charts/karpenter-ec2-node-class`](../../../charts/karpenter-ec2-node-class/). `instanceStorePolicy: RAID0` puts kubelet, containerd images, and `emptyDir` on the instance's local NVMe. The root EBS volume keeps the AMI's size
- **[node_pool](node_pool/)**: the `gpu-spot-node-pool` and `gpu-on-demand-node-pool` `NodePool`s, one unit each in the stack, via the chart bundled under [`charts/karpenter-node-pool`](../../../charts/karpenter-node-pool/). Both carry the `karpenter.sh/workload-class=gpu:NoSchedule` taint and Cilium's startup taint. Both use the `gpu-ec2-node-class` `EC2NodeClass`
- **[app_of_apps](app_of_apps/)**: the `app-of-apps-gpu` root `Application`, syncing `apps/features/gpu` from the same app-of-apps revision as core. It applies after every other unit of the feature and destroys before them. Its finalizer deletes the child apps, and so the `gpu` namespace
- **[`gpu-namespaces`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/manifests/features/gpu/namespaces)** (app-of-apps): the `gpu` namespace. Not deployed by these units
- **[`gpu-nvidia-device-plugin`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/charts/features/gpu/nvidia-device-plugin)** (app-of-apps): the DaemonSet advertising `nvidia.com/gpu` on GPU nodes. Not deployed by these units
- **[`gpu-dcgm-exporter`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/charts/features/gpu/dcgm-exporter)** (app-of-apps): the DaemonSet exporting GPU metrics to Prometheus, and the **GPU** Grafana dashboard. Not deployed by these units
- **[`gpu-smoke-test`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/manifests/features/gpu/smoke-test)** (app-of-apps): suspended `CronJob` running a CUDA sample on a GPU node, on demand. Not deployed by these units

## Scheduling a Pod on a GPU Node

A pod needs the taint's toleration and a `nvidia.com/gpu` limit. A `karpenter.sh/capacity-type` nodeSelector picks the pool. AWS can reclaim `spot` nodes with a 2 minute notice. `on-demand` nodes cost more and are never reclaimed. Without the nodeSelector, the pod lands on either pool in no set order. Kubernetes has no GPU memory resource, so a minimum GPU memory is a node affinity on `karpenter.k8s.aws/instance-gpu-memory`, in MiB. Karpenter picks the cheapest allowed instance type matching it and the pod's CPU and memory requests.

```yaml
spec:
  tolerations:
    - key: karpenter.sh/workload-class
      value: gpu
      effect: NoSchedule
  nodeSelector:
    karpenter.sh/capacity-type: spot # or on-demand
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

## Running the GPU Smoke Test

The [`gpu-smoke-test`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/manifests/features/gpu/smoke-test) `CronJob` runs one CUDA sample on a GPU node per trigger:

```bash
kubectl create job --from=cronjob/gpu-smoke-test <name> -n gpu
kubectl wait --for=condition=complete job/<name> -n gpu --timeout=15m
kubectl logs job/<name> -n gpu
```

A passing run logs `Test PASSED`.

## Upstream Dependencies

- **[`karpenter/iam`](../../eks/addons/karpenter/iam/)** (core): `ec2_node_class` reads the node IAM role name from it. The stack's `autoinclude` declares the dependency, from the `core_karpenter_iam_path` value
- **[`karpenter/helm`](../../eks/addons/karpenter/helm/)** (core): `ec2_node_class` applies once Karpenter and its CRDs exist. The stack's `autoinclude` declares the dependency, from the `core_karpenter_helm_path` value
- **[`argocd/app_of_apps`](../../eks/addons/argocd/app_of_apps/)** (core): `app_of_apps` applies once core's root app is Synced and Healthy. The stack's `autoinclude` declares the dependency, from the `core_app_of_apps_path` value
