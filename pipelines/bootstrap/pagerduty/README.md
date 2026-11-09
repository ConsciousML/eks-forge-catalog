{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# PagerDuty Bootstrap

In this guide, you'll set up [PagerDuty](https://www.pagerduty.com/) so Alertmanager can page you. An alert posted to Slack waits until someone reads the channel. A page doesn't wait: PagerDuty contacts you directly, by email by default, so you can act on the alert right away.

Only `prod` pages. `dev` and CI get a PagerDuty service too, but they never page unless you set [`PAGERDUTY_ENABLED`](/docs/reference/environment_variable/#pagerduty_enabled) to `true`.

:::warning
This guide needs to be performed only once per catalog fork before running the [deployment](/docs/quickstart/deployment/).
:::

First, create your PagerDuty account:
1. Go to [PagerDuty's sign-up page](https://www.pagerduty.com/sign-up/)
2. In `Work Email`, enter your email and click `Continue`. The trial rejects some personal email domains, such as `gmail.com`, `yahoo.com`, and `icloud.com`
3. Fill in `First Name`, `Last Name`, `Company`, and `Country`, then click `Continue`
4. Choose a `Password` and click `Continue`
5. In `Name your account`, edit the account URL. It's pre-filled from your email domain (e.g. `hotmail.pagerduty.com`), but account URLs are unique across PagerDuty and need at least 5 characters, so pick your own (e.g. `your-org-name.pagerduty.com`)
6. In `Select your service region`, choose `U.S.A.` or `E.U.`. You can't change it later, so note which one you chose
7. Check the `Terms of Service` and `Privacy Policy` box, and click `Create Account`

PagerDuty then opens an onboarding. You don't need it, so skip it:
1. On the Slack integration prompt, which comes first, click `Skip for now`
2. Exit the onboarding

Your account already has what the pipeline needs. To see it, click `Schedules` in the sidebar, then `Escalation Policies`. You should see a policy named `Default`, with you on it. The pipeline assigns its services to this policy. Your account also has an unused `Default Service`, which you can leave as is.

Your signup email is your only contact method by default, which is enough to get paged.

Next, create the API key Terraform uses to create the services:
1. Click `Configuration`, then `Integrations`, then `API Access Keys`
2. Click `Create New API Key`
3. Enter a description (e.g. `eks-forge`), leave `Read-only` unchecked, and create the key
4. Copy the key now. PagerDuty shows it only once

Then, add the key and your service region to your `.env` file, as described in the [`PAGERDUTY_TOKEN` and `PAGERDUTY_SERVICE_REGION`](/docs/reference/environment_variable/#pagerduty_token-and-pagerduty_service_region) reference. Set `PAGERDUTY_SERVICE_REGION` to `eu` if you chose `E.U.`, and leave it empty if you chose `U.S.A.`:
```bash
export PAGERDUTY_TOKEN=<your-api-key>
export PAGERDUTY_SERVICE_REGION=
```

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
