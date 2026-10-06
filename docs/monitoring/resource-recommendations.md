{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Read a Resource Recommendation

Now that you've completed [Explore Your Network Flows](/docs/monitoring/get-started/network-flows/), you'll open the [Goldilocks](https://goldilocks.docs.fairwinds.com/) dashboard and read the CPU and memory it recommends for `podinfo`. You'll only look: nothing on this page changes your cluster.

## Open the Goldilocks Dashboard
Like Grafana and Hubble, the Goldilocks dashboard is only reachable using Tailscale. If you disconnected, connect to Tailscale by running `tailscale up`, or with the button in the Tailscale client.

Open `https://goldilocks.private.dev.<base_domain>` in your browser (replace `<base_domain>` with the `base_domain` you set in `pipelines/dns.hcl` during [DNS Bootstrap](/docs/quickstart/bootstrap/setup_dns/)). There's no login: you should see the list of your cluster's namespaces.

## Find Podinfo
Click the `podinfo` namespace. You should see the `podinfo` Deployment, with its `podinfo` container.

## Read the Recommendation
Every container declares how much CPU and memory it needs, with two values for each:
- a [request](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits): the amount Kubernetes reserves for the container when it places the pod on a node
- a [limit](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits): the most the container is allowed to use

Set them too high and you pay for capacity the container never uses. Set them too low and the app slows down or gets killed. Goldilocks recommends values based on real usage.

Under the container, notice the two blocks, **Guaranteed QoS** and **Burstable QoS**. Each one shows the current `requests` and `limits` of the container next to the recommended ones.

Look at the **Guaranteed QoS** block. Its recommended CPU and memory are computed by the [VPA recommender](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) from what the `podinfo` pods actually used.

## Find Where the Current Values Come From
Open [`manifests/podinfo/podinfo-deployment.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/manifests/podinfo/podinfo-deployment.yaml) in the app of apps repository, and find the `resources` of the `podinfo` container:
```yaml
          resources:
            requests:
              cpu: 50m
              memory: 35M
            limits:
              cpu: 50m
              memory: 35M
```

Notice these are the current values the dashboard shows. Goldilocks only displays recommendations: the `requests` and `limits` of `podinfo` change when this file changes.

## What's Next
Next, see [Alerts](/docs/monitoring/get-started/alerts/) to follow an alert to Slack.
