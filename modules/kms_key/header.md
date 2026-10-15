# `kms_key` Terraform Module Reference

The [`kms_key` module](../kms_key/) creates a symmetric [AWS KMS](https://aws.amazon.com/kms/) customer managed key with automatic rotation, and an alias pointing at it. The key uses the default key policy, so IAM policies control who can use it.
