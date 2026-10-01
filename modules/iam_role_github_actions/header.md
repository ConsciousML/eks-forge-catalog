# `iam_role_github_actions` Terraform Module Reference

The [`iam_role_github_actions` module](../iam_role_github_actions/) creates an IAM role that GitHub Actions assumes through [OpenID Connect (OIDC)](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect), with a trust policy scoped to one repository and branch (or every branch, with `*`), and optional inline policies.
