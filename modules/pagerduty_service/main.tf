# Looked up, not created. The Free plan allows a single escalation policy, and every new account
# already has one named Default.
data "pagerduty_escalation_policy" "this" {
  name = var.escalation_policy_name
}

resource "pagerduty_service" "this" {
  name              = "${var.environment}-eks-forge"
  description       = "Alertmanager page alerts of the ${var.environment} environment"
  escalation_policy = data.pagerduty_escalation_policy.this.id
  # Alertmanager sends resolve events, so incidents never auto-resolve on a timer.
  auto_resolve_timeout = "null"
}

resource "pagerduty_service_integration" "this" {
  name    = "Alertmanager"
  type    = "events_api_v2_inbound_integration"
  service = pagerduty_service.this.id
}
