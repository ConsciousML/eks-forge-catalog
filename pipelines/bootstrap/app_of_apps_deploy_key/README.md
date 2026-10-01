{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# App of Apps Deploy Key Bootstrap

In this guide, you'll create a write deploy key on your [app of apps fork](/docs/applications/get-started/app-of-apps-setup/#fork-the-app-of-apps-repository), so its CI can push the generated chart READMEs back to your PRs.

:::warning
This guide needs to be performed only once per app of apps fork, after completing [Point the Catalog at Your Fork](/docs/applications/get-started/app-of-apps-setup/#point-the-catalog-at-your-fork).
:::

This [bootstrap pipeline](/docs/quickstart/bootstrap) adds a `Helm Docs Deploy Key` deploy key with write access to your app of apps fork, and stores its private key as the `HELM_DOCS_DEPLOY_KEY` GitHub Actions secret on the same fork.

First, set up your `.env` file by following the [Prerequisite](/docs/reference/environment_variable/#prerequisite) and [`GITHUB_TOKEN`](/docs/reference/environment_variable/#github_token) sections of the environment variables reference.

Next, run the following from the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/app_of_apps_deploy_key/
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Then, list the GitHub Actions secrets of your app of apps fork, replacing `<owner>/<repo>`:
```bash
gh secret list -R <owner>/<repo>
```

You should see `HELM_DOCS_DEPLOY_KEY`. This is the secret your app of apps CI uses to push the generated chart READMEs.

Finally, list the deploy keys of your app of apps fork:
```bash
gh repo deploy-key list -R <owner>/<repo>
```

You should see `Helm Docs Deploy Key` with `read-write` permission.

For more information about this bootstrap, read the [App of Apps Deploy Key](/docs/reference/bootstrap/app_of_apps_deploy_key/) reference.
