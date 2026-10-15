output "key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.this.arn
}

output "alias_arn" {
  description = "ARN of the KMS key alias"
  value       = aws_kms_alias.this.arn
}
