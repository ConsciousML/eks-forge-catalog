{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# How to Manage On-Call in PagerDuty

This guide shows you how to choose who [PagerDuty](https://www.pagerduty.com/) pages, and how. You need it when someone other than the person who signed up should be on call.

It assumes you've followed the [PagerDuty Bootstrap](/docs/quickstart/bootstrap/pagerduty/). To see a page reach you end to end first, follow [Get Your First Page](/docs/monitoring/paging/get-your-first-page/).

Terraform manages none of this: you set it in the PagerDuty web console, at your account URL (e.g. `https://your-org-name.pagerduty.com`). Every EKS Forge service (`dev-eks-forge`, `catalog-eks-ci-eks-forge`, `staging-eks-forge`, and `prod-eks-forge`) pages through the same escalation policy, so what you set here applies to every environment.

The [Free plan](https://www.pagerduty.com/pricing/incident-management/) limits what you can set up. Each step below names the limit that applies to it.

## Add People
Add each person you want on call from **People** › **Users**, as in PagerDuty's [Manage Users](https://docs.pagerduty.com/account-admin/manage-users). The Free plan allows 5 users in the account, you included.

## Set How People Are Notified
Each user sets their contact methods and notification rules in their own profile, as in PagerDuty's [User Profile](https://docs.pagerduty.com/account-admin/user-profile). By default, a user's only contact method is the email they signed up with, so ask each person you added to add theirs.

Prefer push and email: they're unlimited. SMS and voice are capped:
- **Trial**: 100 per user and 500 per account. Past that, PagerDuty blocks SMS and voice until its Support lifts the block, even if you upgrade.
- **Free plan**: 100 per month, across the whole account.

For push notifications, each person installs the mobile app, as in [Install the PagerDuty App](/docs/monitoring/paging/get-your-first-page/#install-the-pagerduty-app).

## Create the On-Call Schedule
Create a schedule that rotates the people you added, from **Schedules** › **Schedules** › **New Schedule**, as in PagerDuty's [Schedule Basics](https://docs.pagerduty.com/incident-management/schedules/schedule-basics). The Free plan allows one schedule.

## Set the Escalation Rules
Every EKS Forge service pages through the `Default` escalation policy. Edit it from **Schedules** › **Escalation Policies**, as in PagerDuty's [Escalation Policy Basics](https://docs.pagerduty.com/incident-management/schedules/escalation-policies). Make your schedule the target of its first rule, then add a rule per extra level if needed (e.g. a backup who's paged when nobody acknowledges). The Free plan allows one escalation policy, so you can't add another.

:::warning
Never rename `Default`. The [PagerDuty bootstrap](/docs/quickstart/bootstrap/pagerduty/) looks the policy up by name, so its next apply fails.
:::

## Change a Service's Settings
:::warning
Don't change a service's name, escalation policy, auto-resolve, or acknowledgement timeout in the web console. The next apply of the PagerDuty bootstrap reverts them.
:::

Change them in the [`pagerduty_service` module](/docs/reference/terraform_modules/pagerduty_service/) of your catalog fork instead, as in [Add or Edit a Unit](/docs/iac/add-a-unit/). Then ship the change to `staging` and `prod` with [Release an IaC Change](/docs/iac/release-an-iac-change/).
