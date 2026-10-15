resource "aws_kms_key" "this" {
  description             = var.description
  enable_key_rotation     = true
  deletion_window_in_days = var.deletion_window_in_days
  tags                    = var.tags

  # Deleting the key makes all data it encrypted unreadable.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "this" {
  name          = var.alias_name
  target_key_id = aws_kms_key.this.key_id
}
