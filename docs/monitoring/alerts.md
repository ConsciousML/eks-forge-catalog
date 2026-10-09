{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Follow an Alert

In this guide, you'll follow an alert from [Prometheus](https://prometheus.io/) to [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) to Slack. You'll only look: nothing on this page changes your cluster.

## Find a Firing Alert in Prometheus
Like your other tools, Prometheus is only reachable using Tailscale. If you disconnected, connect to Tailscale by running `tailscale up`, or with the button in the Tailscale client.

Open `https://prometheus.private.dev.<base_domain>` in your browser (replace `<base_domain>` with the `base_domain` you set in `pipelines/dns.hcl` during [DNS Bootstrap](/docs/quickstart/bootstrap/setup_dns/)). In the top menu, click **Alerts**. You should see the alert rules of your cluster and the state of each one.

Type `Watchdog` in the search bar. You should see one alert in the **Firing** state.

Prometheus checks each [alert rule](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) against your metrics. A rule fires while its condition holds. `Watchdog` always fires. It lets you check that alerts reach you.

Click the alert to expand it. Notice its `alertname="Watchdog"` and `severity="none"` labels.

## See It in Alertmanager
Prometheus sends its firing alerts to Alertmanager. Alertmanager decides where to notify you. Open `https://alertmanager.private.dev.<base_domain>` in your browser. There's no login: you should see the list of firing alerts.

Find the one with `alertname="Watchdog"`. Notice it carries the same labels as in Prometheus.

## Read the Notification in Slack
Open the `#dev-watchdog` channel of your Slack workspace. You joined it in [Slack Bootstrap](/docs/quickstart/bootstrap/slack/). You should see a message from the `alertmanager` app with this title:
```text
[FIRING:1] Watchdog (none)
```

The message also shows the summary and the description of the alert.

Notice your other `dev-` channels, such as `#dev-k8s-critical`. Each one receives the alerts of one part of your cluster at one severity. They stay empty on a healthy cluster.

## When You Receive an Alert
One day, a message will land in one of these channels. Its title names the alert and its severity. Its description tells you what is wrong.

From there, find the cause with `kubectl` and the tools you explored in this tutorial:
- `kubectl get` and `kubectl describe` to check the state of the resource the alert names
- [Explore Your Metrics](/docs/monitoring/get-started/metrics/) to see when the problem started
- [Explore Your Logs](/docs/monitoring/get-started/logs/) to read what the pod logged at that time
- [Explore Your Network Flows](/docs/monitoring/get-started/network-flows/) to check whether its traffic is dropped

## What's Next
You've completed [Monitor Your Cluster](/docs/monitoring/get-started/). You now know where to find the metrics, logs, network flows, resource recommendations, control plane metrics, and alerts of your cluster.

When you're done with your `dev` cluster, go back to [Destroy the Infrastructure](/docs/quickstart/deployment/#destroy-the-infrastructure).
