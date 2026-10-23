{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# DNS Bootstrap

In this guide, you'll set up your domain to be able to expose your cluster apps through it during the [deployment](/docs/quickstart/deployment/).

:::warning
This guide needs to be performed only once per catalog fork before running the [deployment](/docs/quickstart/deployment/).
:::

This [bootstrap pipeline](/docs/quickstart/bootstrap) creates a public [Route 53](https://aws.amazon.com/route53/) [hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html), a container for the DNS records that route traffic to your domain. It's what exposes your internet-facing apps, and what [ACM](https://aws.amazon.com/certificate-manager/) uses to validate their [TLS certificate](https://aws.amazon.com/what-is/ssl-certificate/), so they can be reached over [HTTPS](https://en.wikipedia.org/wiki/HTTPS).

First, we'll update the [`pipelines/dns.hcl`](../../dns.hcl) configuration file in your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```hcl
locals {
  base_domain            = "yourdomain.com"
  subdomain_argocd       = "argocd"
  ...
}
```
Replace the `base_domain` value with your base domain url. Keep the `subdomain_*` keys: they name the hostname of each app (e.g. `argocd.private.dev.yourdomain.com`).

Then, commit and push it, so the CI/CD pipelines use your domain:
```bash
git add pipelines/dns.hcl
git commit -m "chore: set the base domain"
git push origin main
```

:::info
Each subdirectory provisions its own hosted zone, giving that environment its own subdomain, named after the `environment` value in its `environment.hcl`:
```
setup_dns/
├── dev/   # dev.yourdomain.com
└── ci/    # catalog-eks-ci.yourdomain.com, used by the catalog CI
```
:::

Follow the steps below for `dev`, then again for `ci`. In each command, replace `<environment>` with the directory name (`dev` or `ci`), and `<subdomain>` with its subdomain (`dev` or `catalog-eks-ci`).

First, run the following from the root directory of [your fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
cd pipelines/bootstrap/setup_dns/<environment>
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Read [Infrastructure as Code](/docs/iac) for a high-level overview of TG.

:::note
On the first run, `--backend-bootstrap` automatically creates the [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) holding the [Terraform state](https://developer.hashicorp.com/terraform/language/state). More information in the [Terragrunt state backend documentation](https://docs.terragrunt.com/features/units/state-backend/).
:::

Then, retrieve the 4 nameservers from this pipeline output:
```bash
terragrunt stack output --json setup_dns.route53_hosted_zone.name_servers
```

You should see something similar to:
```txt
{
  "setup_dns": {
    "route53_hosted_zone": {
      "name_servers": [
        "<nameserver_1>",
        "<nameserver_2>",
        "<nameserver_3>",
        "<nameserver_4>"
      ]
    }
  }
}
```

In your domain registrar, add 4 NS records for the subdomain using the nameservers from the output above.

| Type | Host | Value |
|------|------|-------|
| NS | `<subdomain>` | `ns-123.awsdns-12.com` |
| NS | `<subdomain>` | `ns-456.awsdns-34.net` |
| NS | `<subdomain>` | `ns-789.awsdns-56.org` |
| NS | `<subdomain>` | `ns-012.awsdns-78.co.uk` |

The NS record type delegates management of `<subdomain>.yourdomain.com` to Route 53's nameservers.

Finally, verify that the NS records are propagated:
```bash
dig NS <subdomain>.yourdomain.com
```

Delegation is working when 4 AWS nameservers appear in the `ANSWER SECTION`.

You can also confirm this visually in the [Route 53 console](https://console.aws.amazon.com/route53/v2/hostedzones). You should see your newly created hosted zone listed. Click it to see its records.

Once `dev` works, go back to the root of your fork and repeat these steps for `ci`:
```bash
cd ../../../..
```

For more information about this bootstrap, read the [DNS Bootstrap](/docs/reference/bootstrap/setup_dns/) reference.
