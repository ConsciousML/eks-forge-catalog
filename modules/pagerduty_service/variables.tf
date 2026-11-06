variable "token" {
  description = "PagerDuty REST API key (General Access, not read-only). Used to create the service and its integration"
  type        = string
  sensitive   = true
}

variable "service_region" {
  description = "PagerDuty service region of the account, chosen at signup. Empty for US, eu for EU"
  type        = string
  default     = ""

  validation {
    condition     = contains(["", "eu"], var.service_region)
    error_message = "service_region must be empty (US) or eu."
  }
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod) used to prefix the service name so environments don't collide in the same account"
  type        = string
}

variable "escalation_policy_name" {
  description = "Name of the existing escalation policy assigned to the service"
  type        = string
  default     = "Default"
}
