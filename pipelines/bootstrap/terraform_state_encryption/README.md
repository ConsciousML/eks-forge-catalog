{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Terraform State Encryption Bootstrap

Your [Terraform state](https://opentofu.org/docs/language/state/) holds the passwords and keys your infrastructure creates. In this guide, you'll create the [AWS KMS](https://aws.amazon.com/kms/) key that encrypts every state and plan of your catalog fork, so they can't be read from the state bucket.

:::warning
This guide needs to be performed only once per catalog fork, before every other [bootstrap pipeline](/docs/quickstart/bootstrap) and the [deployment](/docs/quickstart/deployment/). They can't write their state until the key exists.
:::

This [bootstrap pipeline](/docs/quickstart/bootstrap) creates a [customer managed KMS key](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#customer-mgn-key), rotated every year, and an [alias](https://docs.aws.amazon.com/kms/latest/developerguide/kms-alias.html) pointing at it. [`root.hcl`](/docs/reference/hcl_configuration/#roothcl) then encrypts your states twice with it: S3 encrypts the state objects it stores, and [OpenTofu](https://opentofu.org/docs/language/state/encryption/) encrypts each state and plan before writing it. The state bucket and your local `.terragrunt-cache` only hold ciphertext.

First, run the following [Terragrunt](/docs/iac) commands from the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/terraform_state_encryption
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

:::note
On the first run, `--backend-bootstrap` automatically creates the [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) holding the [Terraform state](https://developer.hashicorp.com/terraform/language/state). More information in the [Terragrunt state backend documentation](https://docs.terragrunt.com/features/units/state-backend/).
:::

Then, check that the key is ready:
```bash
aws kms describe-key --key-id alias/bootstrap-catalog-eks-tofu-state --query KeyMetadata.KeyState --output text
```

You should see `Enabled`.

:::info
If your fork deployed stacks before this pipeline existed, their states are still plaintext and OpenTofu refuses to read them. Migrate them by following [A Unit Can't Read Its Unencrypted State](/docs/troubleshooting/iac/#a-unit-cant-read-its-unencrypted-state).
:::

For more information about this bootstrap, read the [Terraform State Encryption](/docs/reference/bootstrap/terraform_state_encryption/) reference.
