{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# PagerDuty Bootstrap

In this guide, you'll set up [PagerDuty](https://www.pagerduty.com/) so Alertmanager can page you. An alert posted to Slack waits until someone reads the channel. A page doesn't wait: PagerDuty contacts you directly, by email by default, so you can act on the alert right away.

Only `prod` pages. `dev` and CI get a PagerDuty service too, but they never page unless you set [`PAGERDUTY_ENABLED`](/docs/reference/environment_variable/#pagerduty_enabled) to `true`.

:::warning
This guide needs to be performed only once per catalog fork before running the [deployment](/docs/quickstart/deployment/).
:::

First, create your PagerDuty account:
1. Go to [PagerDuty's sign-up page](https://www.pagerduty.com/sign-up/) and fill in the form
2. On the step where you name your account URL, choose the service region, `USA` or `EU`. You can't change it later
3. Edit the account URL, which is pre-filled from your email domain (e.g. `hotmail.pagerduty.com`). Account URLs are unique across PagerDuty and need at least 5 characters, so pick your own

PagerDuty then starts an onboarding. Click `Skip for now` on the Slack integration prompt, then exit the onboarding. You don't need it: your account already has an escalation policy named `Default`, with you on it, which the pipeline assigns its services to. You can see it in the sidebar, under `Schedules` > `Escalation Policies`. Your signup email is your only contact method by default, which is enough to get paged.

Next, create the API key Terraform uses to create the services:
1. Go to `Configuration` > `Integrations` > `API Access Keys`, and click `Create New API Key`
2. Give the key a description, leave `Read-only` unchecked, and create it
3. Copy the key now. PagerDuty shows it only once

Then, add [`PAGERDUTY_TOKEN` and `PAGERDUTY_SERVICE_REGION`](/docs/reference/environment_variable/#pagerduty_token-and-pagerduty_service_region) to your `.env` file. Set `PAGERDUTY_SERVICE_REGION` to `eu` for an EU account, and leave it empty for a US account.

You'll deploy two pipelines:
- [`services`](services/), which creates a PagerDuty service for each environment (`dev-eks-forge` and `catalog-eks-ci-eks-forge`), and stores its integration key in AWS Secrets Manager for Alertmanager
- [`gh_secret`](gh_secret/), which adds `PAGERDUTY_SERVICE_REGION` to GitHub Actions secrets, so the environments CI deploys send events to your region's PagerDuty endpoint

Now, run the following [Terragrunt](/docs/iac/) commands from the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/pagerduty
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

In PagerDuty, go to `Services` > `Service Directory`. You should see `dev-eks-forge` and `catalog-eks-ci-eks-forge`.

Finally, list the GitHub Actions secrets of your fork:
```bash
gh secret list
```

You should see `PAGERDUTY_SERVICE_REGION`. It holds `us` for a US account, since a GitHub secret can't be empty.

For more information, read the following references:
- [PagerDuty Service](/docs/reference/bootstrap/pagerduty_service/)
- [PagerDuty GitHub Secrets](/docs/reference/bootstrap/pagerduty_github_secrets/)
