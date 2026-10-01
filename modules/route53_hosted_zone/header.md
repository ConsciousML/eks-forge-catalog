# `route53_hosted_zone` Terraform Module Reference

The [`route53_hosted_zone` module](../route53_hosted_zone/) creates or looks up a [Route 53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html), either public (internet-facing, requires NS delegation for ACM validation) or private (VPC-scoped, no delegation).
