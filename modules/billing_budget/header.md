# `billing_budget` Terraform Module Reference

The [`billing_budget` module](../billing_budget/) creates an [AWS Budget](https://aws.amazon.com/aws-cost-management/aws-budgets/) that emails a notification for each USD threshold monthly spend crosses. `notification_type` sets whether thresholds compare against `ACTUAL` or `FORECASTED` spend.
