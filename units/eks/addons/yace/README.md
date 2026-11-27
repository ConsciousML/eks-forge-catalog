# YACE

Provisions the AWS-side Pod Identity resources for [YACE](https://github.com/prometheus-community/yet-another-cloudwatch-exporter), which exports the CloudWatch metrics of the ALBs tagged `eks-forge.io/slo-service` to Prometheus. podinfo's SLIs are measured at its ALB from these metrics.

## Concepts

- [YACE](https://github.com/prometheus-community/yet-another-cloudwatch-exporter)
- [ALB CloudWatch Metrics](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_role](iam_role/)**: Creates an IAM role bound to the `yace` service account in the `yace` namespace via Pod Identity, with read access to CloudWatch metrics and resource tags. None of these actions supports resource-level permissions
- **[`yace`](https://github.com/ConsciousML/eks-forge-app-of-apps/tree/main/charts/monitoring/yace)** (app-of-apps): deploys YACE itself, using the Pod Identity association `iam_role` creates. Not deployed by this unit

## Upstream Dependencies

- **[`units/vpc/endpoints`](../../../vpc/endpoints/)**: the `tagging` interface endpoint, created for `aws-lbc`. Private DNS resolves the Resource Groups Tagging API to it, so its pinned IPs reach the chart through `app_of_apps`. CloudWatch and STS have no endpoint, since YACE isn't critical. The chart reaches them through its public egress rule
