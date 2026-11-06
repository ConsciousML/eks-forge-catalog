terraform {
  required_providers {
    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = "= 3.37.0"
    }
  }

  required_version = ">= 1.9.1"
}
