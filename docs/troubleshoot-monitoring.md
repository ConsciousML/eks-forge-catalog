{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
This guide shows you how to fix the monitoring tools of your cluster.

Go to the section of your problem below.

## The Hubble UI Shows No Flows

The Hubble UI opens, but a namespace shows no flow, or some of its pods are missing from the service map. Cilium only sees the pods created after `cilium-agent` started on their node, so a pod created before it has no [CiliumEndpoint](https://docs.cilium.io/en/stable/network/kubernetes/ciliumendpoint/) and stays invisible to Hubble (see [How Network Policies Work](/docs/security/how-network-policies-work/)).

Compare the pods of the namespace with its endpoints, replacing `<namespace>`. A pod without an endpoint of the same name is the one Hubble can't see:
```bash
kubectl get pod -n <namespace>
kubectl get ciliumendpoints -n <namespace>
```

Pods that use the network of their node, such as `cilium` and `kube-proxy`, never have an endpoint.

:::warning
The script below restarts every workload that has a pod without an endpoint, in every namespace. Run it when a restart of these workloads is acceptable.
:::

From the root of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), run [`scripts/restart-missing-cilium-endpoints.sh`](https://github.com/ConsciousML/eks-forge-catalog/blob/main/scripts/restart-missing-cilium-endpoints.sh):
```bash
scripts/restart-missing-cilium-endpoints.sh
```

It logs each workload it restarts, waits for the rollouts, then scans the cluster again. When every pod has its endpoint, it ends with:
```text
[INFO] Done, no pods missing a CiliumEndpoint
```
