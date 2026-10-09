{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Explore Your Network Flows

In this guide, you'll look at the traffic between your pods with [Hubble](https://github.com/cilium/hubble), first in its UI, then with its CLI.

## Open the Hubble UI
Like Grafana and Prometheus, the Hubble UI is only reachable using Tailscale. If you disconnected, connect to Tailscale by running `tailscale up`, or with the button in the Tailscale client.

Open `https://hubble.private.dev.<base_domain>` in your browser (replace `<base_domain>` with the `base_domain` you set in `pipelines/dns.hcl` during [DNS Bootstrap](/docs/quickstart/bootstrap/setup_dns/)). There's no login: you should see the Hubble UI asking you to choose a namespace.

## Look at the Flows of Podinfo
In the namespace dropdown at the top, select `podinfo`. You should see the service map: a `podinfo` box, with arrows coming from everything that sends it traffic.

Notice the three boxes pointing at `podinfo`:
- `world`: the load balancer serving the page you opened in [Access the Podinfo App](/docs/quickstart/deployment/#access-the-podinfo-app)
- `host`: the node checking that the pod is alive
- `prometheus`: Prometheus collecting the metrics you queried in [Explore Your Metrics](/docs/monitoring/get-started/metrics/#run-a-query-in-prometheus)

Below the map, the table lists one row per flow, with its source, destination, destination port, and verdict. Notice every verdict is `forwarded`: the traffic was allowed.

Now, reload `https://podinfo.public.dev.<base_domain>` a few times. Notice the new rows from `world` to `podinfo` on port `9898`.

## Watch Flows from Your Terminal
Hubble also comes with a CLI. From the root of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), where mise installs `hubble`, run:
```bash
hubble observe -P | grep -v "Unsupported L3"
```

You should see the latest flows of your whole cluster, one per line, with the source on the left, the destination on the right, and a `FORWARDED` verdict:
```text
Oct  6 10:15:03.412: monitoring/prometheus-kube-prometheus-stack-prometheus-0:51234 (ID:30122) -> podinfo/podinfo-7d9f8c6b5-x2kqz:9898 (ID:21034) to-endpoint FORWARDED (TCP Flags: SYN)
...
```

## Look for Dropped Flows
Now, only ask for the flows that were dropped:
```bash
hubble observe --verdict DROPPED -P | grep -v "Unsupported L3"
```

You should see no output. The [network policies](/docs/security/how-network-policies-work/) of your cluster allow all the traffic its tools need, so nothing is dropped.

## What's Next
Next, see [Resource Recommendations](/docs/monitoring/get-started/resource-recommendations/) to read the recommended requests and limits of a workload.
