## Deletion

The key has `prevent_destroy` set. Anything it encrypted becomes unreadable once the key is deleted. A key scheduled for deletion can be restored with `aws kms cancel-key-deletion` until `deletion_window_in_days` elapses.
