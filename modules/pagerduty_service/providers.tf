provider "pagerduty" {
  token = var.token
  # Empty is the US region.
  service_region = var.service_region
}
