# `deploy_key` Terraform Module Reference

The [`deploy_key` module](../deploy_key/) generates an SSH key pair per target GitHub repository, registers the public key as a [deploy key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys) on that repository, and stores the private key as a GitHub Actions secret in the current repository.
