{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

# Installation

## Fork the EKS Forge Catalog 
EKS Forge is a toolkit containing multiple [repository templates](/docs/architecture/), each with their own responsibilities.
They're meant to be forked and extended.

To get started, you'll fork the catalog, a collection of [Terraform](https://developer.hashicorp.com/terraform) modules and [Terragrunt](https://docs.terragrunt.com/getting-started/terminology/#terragrunt) pipelines, re-usable across multiple environments (`dev`, `staging`, and `prod`).

First, create an empty repository from [GitHub's new repository page](https://github.com/new), private or public. Leave the README, `.gitignore`, and license options unset.

Then, set your GitHub owner (user or organization) and the name of the repository you created, by replacing the `<...>`:
```bash
export GITHUB_OWNER=<your-github-owner>
export CATALOG_REPO_NAME=<your-catalog-repo-name>
```

Clone the catalog and push it to your repository:
```bash
git clone https://github.com/ConsciousML/terragrunt-template-catalog-eks.git $CATALOG_REPO_NAME
cd $CATALOG_REPO_NAME
git remote set-url origin git@github.com:$GITHUB_OWNER/$CATALOG_REPO_NAME.git
git push origin main
git push origin --tags
```

:::warning
Follow these exact steps instead of GitHub's `Fork` button. The [live repository](/docs/deployment/get-started/) pins catalog versions by git tag, and these steps guarantee your repository has them.
:::

## Install the CLI Tools
Stay at the root of your catalog repository.

You'll use multiple CLI tools to deploy and operate EKS Forge.
Luckily, the catalog comes with a [mise-en-place](https://mise.jdx.dev/) configuration that allows you to install them all effortlessly.

Let's start by installing `mise`:
```bash
curl https://mise.run | MISE_VERSION=v2026.4.0 sh
```

All the tools are pinned to a specific version in [`mise.toml`](../mise.toml) and [`mise.local.toml`](../mise.local.toml) files.
Run the following command to install them all at once:
```bash
mise trust
mise install
```

Finally, run the following to automatically activate mise when starting a shell:
- For `zsh`: 
```bash
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc && source ~/.zshrc
```
- For `bash`:
```bash
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && source ~/.bashrc
```

For a different shell type, use the [`mise activate` reference](https://mise.jdx.dev/cli/activate.html).

:::warning
`mise` installed tools are not available system-wise by default.
You'll need to be inside your repository directory to have them loaded in your context.
More information in the [mise shims documentation](https://mise.jdx.dev/dev-tools/shims.html)
:::

## Enable the Pre-commit Hooks
Your fork comes with [prek](https://github.com/j178/prek) hooks, defined in [`.pre-commit-config.yaml`](../.pre-commit-config.yaml). They format, validate, and lint your Terraform and Terragrunt code, and scan it for secrets with [Trivy](https://trivy.dev/). These are the same checks the [CI](/docs/ci-cd/) runs on every pull request, so you'll catch issues before you push.

`mise` already installed `prek`. Wire the hooks into git:
```bash
prek install
```

Run every hook against the whole repository:
```bash
prek run --all-files
```
The first run takes a few minutes, since `OpenTofu validate` downloads the providers of every module. You'll see each hook pass:
```
OpenTofu fmt.............................................................Passed
OpenTofu validate........................................................Passed
tflint...................................................................Passed
Terragrunt hcl fmt.......................................................Passed
Trivy secret scan........................................................Passed
```

From now on, the hooks run on the files you change each time you `git commit`.