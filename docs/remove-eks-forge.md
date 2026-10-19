{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
## Catalog Repository
### Destroy the Dev Stack
Like for `staging` and `prod`, disconnect from Tailscale before destroying, by running `tailscale down` or with the button in the Tailscale client.

Then, run the following from the root of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack clean
terragrunt stack generate
terragrunt run --all destroy --non-interactive --no-stack-generate
```

If you added an environment with [Add a Dev Environment](/docs/iac/add-a-dev-environment/), destroy its stack too, as in [Destroy the Environment](/docs/iac/add-a-dev-environment/#destroy-the-environment).

### Destroy the Catalog Bootstrap
From the root of your catalog fork, destroy the [bootstrap pipelines](/docs/quickstart/bootstrap/), except the state KMS key. The other states need it to decrypt, and its `prevent_destroy` would fail the run:
```bash
source .env
cd pipelines/bootstrap
terragrunt run --all destroy --non-interactive --filter '!./terraform_state_encryption/**'
```

Then, schedule the deletion of the key:
```bash
aws kms schedule-key-deletion --key-id $(aws kms describe-key --key-id alias/bootstrap-catalog-eks-tofu-state --query KeyMetadata.KeyId --output text)
```

AWS deletes it after a waiting period, and you can restore it until then (see [Deletion](/docs/reference/terraform_modules/kms_key/#deletion)).

Finally, in your domain registrar, remove the NS records of the `dev` and `ci` subdomains, and of any environment you added, for the same reason as for `staging` and `prod`.
