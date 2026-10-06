{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Explore Your Metrics

Now that you've completed [Dev Deployment](/docs/quickstart/deployment/) and your `dev` cluster is running, you'll log in to [Grafana](https://grafana.com/oss/), open one of its bundled dashboards, and run a query in [Prometheus](https://prometheus.io/).

## Connect to Tailscale
Like ArgoCD, Grafana and Prometheus are only reachable using Tailscale. Connect to Tailscale by running `tailscale up`, or with the button in the Tailscale client, as in the [Log In to ArgoCD](/docs/quickstart/deployment/#log-in-to-argocd) step of the dev deployment.

## Log In to Grafana
Open `https://grafana.private.dev.<base_domain>` in your browser (replace `<base_domain>` with the `base_domain` you set in `pipelines/dns.hcl` during [DNS Bootstrap](/docs/quickstart/bootstrap/setup_dns/)) and log in with username `admin`. Retrieve the password with:
```bash
aws secretsmanager get-secret-value \
  --secret-id dev-grafana-password \
  --query SecretString \
  --output text | jq -r .plaintext
```

You should see the Grafana home page.

## Open a Dashboard
In the left menu, click **Dashboards**. You'll see a list of dashboards and folders that were deployed with your cluster. Notice the folders named after your cluster's tools, such as **ArgoCD**, **Karpenter**, and **Loki**.

Type `Namespace (Pods)` in the search bar and open **Kubernetes / Compute Resources / Namespace (Pods)**. At the top of the dashboard, set the **namespace** dropdown to `podinfo`.

You should see the **CPU Usage** and **Memory Usage** panels, with one line per `podinfo` pod. These are the pods serving the page you opened in [Access the Podinfo App](/docs/quickstart/deployment/#access-the-podinfo-app).

## Run a Query in Prometheus
Grafana draws its dashboards from the metrics stored in Prometheus. Now, you'll query them directly.

Open `https://prometheus.private.dev.<base_domain>` in your browser. There's no login: you should see the Prometheus query page.

Type the following query in the expression field and click **Execute**:
```promql
up{namespace="podinfo"}
```

You should see one result per `podinfo` pod, each with the value `1`. It means Prometheus reaches the pod and collects its metrics.

Next, run this query and switch to the **Graph** tab:
```promql
sum(rate(http_requests_total{namespace="podinfo"}[5m]))
```

You should see the number of HTTP requests `podinfo` receives per second over the last hour. Reload `https://podinfo.public.dev.<base_domain>` a few times, wait a minute, and click **Execute** again. Notice the line going up.

## What's Next
Next, see [Logs](/docs/monitoring/get-started/logs/) to query the logs of your pods.
