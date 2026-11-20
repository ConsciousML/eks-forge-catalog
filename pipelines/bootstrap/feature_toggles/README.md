{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Feature Toggles Bootstrap

In this guide, you'll make CI deploy the optional features you enabled. Your `.env` file only exists on your machine, so CI can't read the `FEATURE_<NAME>_ENABLED` toggles it holds. This pipeline copies them to GitHub Actions variables, which CI exports before running Terragrunt.

:::warning
Rerun this guide each time you enable or disable a feature, and once in each new catalog fork, since forks don't inherit GitHub Actions variables.
:::

First, set the toggle of each feature you want to `true` in your `.env` file, as described in the [`FEATURE_GPU_ENABLED`](/docs/reference/environment_variable/#feature_gpu_enabled) reference:
```bash
export FEATURE_GPU_ENABLED=true
```

To disable a feature, destroy it first, as described in its reference. Then remove its line from your `.env` file and unset it in your shell:
```bash
unset FEATURE_GPU_ENABLED
```

You'll deploy one stack, [`feature_toggles`](../../../stacks/feature_toggles/), which adds a GitHub Actions variable for each `FEATURE_<NAME>_ENABLED` set to `true` in your shell, and removes the variable of each one that isn't.

Now, run the following [Terragrunt](/docs/iac/#terragrunt) commands from the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/feature_toggles
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Finally, list the GitHub Actions variables of your fork:
```bash
gh variable list
```

You should see a `FEATURE_<NAME>_ENABLED` variable for each feature you enabled, and none for the others.

For more information, read the [`github_variables`](/docs/reference/terraform_modules/github_variables/) module reference.
