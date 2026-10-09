{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Explore Your Control Plane

In this guide, you'll look at the [control plane](https://kubernetes.io/docs/concepts/architecture/#control-plane-components) of your cluster, which AWS runs for you. First in the [EKS](https://aws.amazon.com/eks/) console, then with `kubectl`. You'll only look: nothing on this page changes your cluster.

## Open the Observability Dashboard
Open the [EKS console](https://console.aws.amazon.com/eks/home#/clusters) in your browser. At the top right, select the region you set in [Catalog Configuration](/docs/quickstart/configuration/#catalog-configuration). You should see `dev-cluster` in the list of clusters.

Click `dev-cluster`, then click **Monitor cluster**. You should see the observability dashboard, with its **Health and performance summary** at the top.

## Look at the Control Plane Metrics
Open the **Control plane monitoring** tab. Under **Metrics**, you should see one graph per metric, such as **APIServer Requests**, **Scheduler attempts**, and **Pending pods**.

Look at the **APIServer Requests** graph. It shows the requests your cluster's API server receives per minute. Every `kubectl` command you run is one of them.

Scroll down to the **View control plane logs in CloudWatch** section. Notice no log type is enabled: `dev` turns the control plane logs off to save costs.

## Fetch the Raw Metrics
The console draws its graphs from metrics AWS collects for you. AWS also serves them through the Kubernetes API of your cluster, so now you'll read them with `kubectl`.

Fetch the metrics of the scheduler, and keep the number of pending pods:
```bash
kubectl get --raw "/apis/metrics.eks.amazonaws.com/v1/ksh/container/metrics" | grep "^scheduler_pending_pods"
```

You should see one line per queue of the scheduler:
```text
scheduler_pending_pods{queue="active"} 0
scheduler_pending_pods{queue="backoff"} 0
scheduler_pending_pods{queue="gated"} 0
scheduler_pending_pods{queue="unschedulable"} 0
```

Notice these are the queues of the **Pending pods** graph you saw in the console. And notice the format: a metric name, its labels, and a value, like the results of the queries you ran in [Explore Your Metrics](/docs/monitoring/get-started/metrics/#run-a-query-in-prometheus).

Next, fetch the metrics of the controller manager the same way, and keep the first lines:
```bash
kubectl get --raw "/apis/metrics.eks.amazonaws.com/v1/kcm/container/metrics" | grep "^workqueue_depth" | head -n 3
```

You should see three lines, each with the name of one of its work queues and the number of items waiting in it:
```text
workqueue_depth{name="<queue>"} 0
...
```

## What's Next
Next, see [Alerts](/docs/monitoring/get-started/alerts/) to follow an alert to Slack.
