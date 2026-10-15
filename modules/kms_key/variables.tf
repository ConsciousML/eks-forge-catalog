variable "alias_name" {
  description = "Alias of the KMS key, starting with `alias/`"
  type        = string
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "Number of days AWS waits before deleting the key once scheduled for deletion. Between 7 and 30"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the KMS key"
  type        = map(string)
  default     = {}
}
