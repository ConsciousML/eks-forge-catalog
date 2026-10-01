# `oidc_provider` Terraform Module Reference

The [`oidc_provider` module](../oidc_provider/) creates, or looks up, the AWS IAM [OIDC identity provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) that lets GitHub Actions authenticate to AWS.

AWS allows only one OIDC provider per URL. The first instance of this module on an account sets `create = true`; every other instance sets `create = false`.
