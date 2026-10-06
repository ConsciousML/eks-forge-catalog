{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Explore Your Logs

Now that you've completed [Explore Your Metrics](/docs/monitoring/get-started/metrics/), you'll browse the logs of your pods and the events of your cluster in Grafana. Both are stored in [Loki](https://grafana.com/oss/loki/).

## Open Explore
Stay connected to Tailscale and go back to Grafana at `https://grafana.private.dev.<base_domain>`. If your session expired, log in again as in the [Log In to Grafana](/docs/monitoring/get-started/metrics/#log-in-to-grafana) step. In the left menu, click **Explore**.

At the top of the page, the data source dropdown shows **Prometheus**. Click it and select **Loki**. You should see an empty Loki query editor.

## Query Pod Logs
On the right of the query editor, switch from **Builder** to **Code**. Type the following query and click **Run query**:
```logql
{namespace="argocd"}
```

You should see the **Logs volume** bars and, below them, the log lines of every ArgoCD pod over the last hour.

Click a log line to expand it. Notice its labels: `namespace`, `pod`, `container`, and `app`. They tell you which pod wrote the line.

Now, use the `app` label to keep the logs of a single ArgoCD component. Run this query:
```logql
{namespace="argocd", app="argocd-application-controller"}
```

You should only see lines from the `argocd-application-controller-0` pod.

Next, add a filter to keep the lines that mention `podinfo`:
```logql
{namespace="argocd", app="argocd-application-controller"} |= "podinfo"
```

You should see the lines ArgoCD writes each time it compares the `podinfo` Application to git, with `podinfo` highlighted in each one.

## Query Cluster Events
Loki also stores the Kubernetes events of your cluster, the ones `kubectl get events` shows. Run this query:
```logql
{job="integrations/kubernetes/eventhandler"}
```

You should see one line per event, each with `kind`, `name`, `reason`, and `msg` fields.

Now, find the events of `podinfo`. At the top right, click the time picker and select **Last 24 hours**. Then, run this query:
```logql
{job="integrations/kubernetes/eventhandler", namespace="podinfo"}
```

You should see the events from when the `podinfo` pods started, such as `reason=Scheduled`, `reason=Pulled`, and `reason=Started`. Notice the `namespace` label works on events as it does on pod logs.

## What's Next
Next, see [Network Flows](/docs/monitoring/get-started/network-flows/) to look at the traffic between your pods.
