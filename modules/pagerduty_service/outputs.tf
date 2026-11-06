output "service_name" {
  description = "Name of the PagerDuty service"
  value       = pagerduty_service.this.name
}

output "integration_key" {
  description = "Events API v2 integration key (routing key) that Alertmanager sends events with"
  value       = pagerduty_service_integration.this.integration_key
  sensitive   = true
}
