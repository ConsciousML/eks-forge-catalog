{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Terraform State Encryption Bootstrap

In this guide, you'll create the key that encrypts your [Terraform state](https://opentofu.org/docs/language/state/), the files where Terragrunt records what it deployed.

:::warning
This guide needs to be performed only once per catalog fork, before the other [bootstrap pipelines](/docs/quickstart/bootstrap) and the [deployment](/docs/quickstart/deployment/).
:::

This [bootstrap pipeline](/docs/quickstart/bootstrap) creates a [customer managed KMS key](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#customer-mgn-key). Every other pipeline encrypts its state with it, so the passwords and keys your infrastructure creates can't be read from the state.

Run the following [Terragrunt](/docs/iac) commands from the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/terraform_state_encryption
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Then, check the key through its [alias](https://docs.aws.amazon.com/kms/latest/developerguide/kms-alias.html):
```bash
aws kms describe-key --key-id alias/bootstrap-catalog-eks-tofu-state --query KeyMetadata.KeyState --output text
```

You should see `Enabled`.

For more information about this bootstrap, read the [Terraform State Encryption](/docs/reference/bootstrap/terraform_state_encryption/) reference.
