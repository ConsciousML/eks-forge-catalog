{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Get Your First Page

Now that you've completed [Follow an Alert](/docs/monitoring/get-started/alerts/), you'll turn paging on in your `dev` cluster, make [podinfo](https://github.com/stefanprodan/podinfo) fail, get paged by [PagerDuty](https://www.pagerduty.com/), and acknowledge the incident.

Before starting, make sure your `dev` cluster is still running. If it isn't, deploy it by following the [Quickstart](/docs/quickstart/).

## Install the PagerDuty App
PagerDuty pages you by email by default. We recommend installing its mobile app too: it pages you with a push notification, and lets you acknowledge an incident from your phone.

Install PagerDuty from the [App Store](https://apps.apple.com/app/pagerduty/id594039512) or [Google Play](https://play.google.com/store/apps/details?id=com.pagerduty.android). Log in with the account URL you chose during the [PagerDuty Bootstrap](/docs/quickstart/bootstrap/pagerduty/) (e.g. `your-org-name.pagerduty.com`) and your signup email. Allow notifications when the app asks. You should see no open incidents.

## Turn Paging On
By default, `dev` never pages: its alerts only reach Slack. Add [`PAGERDUTY_ENABLED`](/docs/reference/environment_variable/#pagerduty_enabled) to the `.env` file of your catalog fork:
```bash
export PAGERDUTY_ENABLED=true
```

Then, apply the `dev` stack again from the root of your catalog fork, as in the [Run the Terragrunt Stack](/docs/quickstart/deployment/#run-the-terragrunt-stack) step of the dev deployment:
```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

When it's done, connect to Tailscale and open `https://alertmanager.private.dev.<base_domain>/#/status` in your browser (replace `<base_domain>` with the `base_domain` you set in `pipelines/dns.hcl` during [DNS Bootstrap](/docs/quickstart/bootstrap/setup_dns/)). Search the **Config** section for `slo-critical-pagerduty`. You should see it as the receiver of the `slo` alerts with `severity="critical"`.

## Make Podinfo Fail
Podinfo answers any request to `/status/<code>` with that HTTP status code. Send it requests that fail with `500` for two minutes:
```bash
for i in $(seq 120); do
  curl -s -o /dev/null -w '%{http_code}\n' https://podinfo.public.dev.<base_domain>/status/500
  sleep 1
done
```

Notice each line prints `500`. Leave the loop running and move on.

## Watch the Alert Fire
Open `https://prometheus.private.dev.<base_domain>` and click **Alerts**. Type `PodinfoAvailabilityBudgetBurn` in the search bar. Within a few minutes, you should see it **Firing** twice: once with `severity="critical"`, and once with `severity="warning"`.

Podinfo has a 99% availability objective. Its requests now fail far faster than that allows, so both alerts fire.

Open the `#dev-slo-critical` channel of your Slack workspace. You should see a message from the `alertmanager` app with this title:
```text
[FIRING:1] PodinfoAvailabilityBudgetBurn (critical)
```

The `warning` one lands in `#dev-slo-warning`.

## Get Paged
At the same time, PagerDuty pages you: you should get an email, and a push notification if you installed the app.

Open the incident:
- In the app, tap the push notification.
- In the web console, open your account URL (e.g. `https://your-org-name.pagerduty.com`) in your browser and click **Incidents**.

You should see a triggered incident on the `dev-eks-forge` service, titled `podinfo is burning its availability error budget`.

Notice only the `critical` alert paged you. The `warning` one stayed in Slack.

## Acknowledge the Incident
Open the incident and click **Acknowledge**, in the web UI or in the app. Its status turns to `Acknowledged`: you've told PagerDuty you're on it, so it stops notifying you.

## Stop the Failure
If the loop is still running, stop it with `Ctrl+C`.

The alerts resolve on their own once podinfo's failure rate drops, about 30 minutes after the last failed request. Slack then posts a `[RESOLVED]` message in both channels, and PagerDuty resolves the incident. You don't need to wait for it.

## Turn Paging Off
Remove the `PAGERDUTY_ENABLED` line from your `.env` file and unset it in your shell:
```bash
unset PAGERDUTY_ENABLED
```

Then, apply the `dev` stack again, as in [Turn Paging On](#turn-paging-on).

If the incident is still open in PagerDuty, click **Resolve**: Alertmanager no longer reports to PagerDuty, so it won't resolve it for you.

## What's Next
You've been paged end to end: an alert fired in Prometheus, reached Slack, and paged you through PagerDuty.

To learn why the alert fired, and why only the `critical` one paged you, see [How SLO Alerting Works](/docs/monitoring/paging/how-slo-alerting-works/).

To choose who else gets paged, and how, see [Manage On-Call in PagerDuty](/docs/monitoring/paging/manage-on-call-in-pagerduty/).

When you're done with your `dev` cluster, go back to [Destroy the Infrastructure](/docs/quickstart/deployment/#destroy-the-infrastructure).
