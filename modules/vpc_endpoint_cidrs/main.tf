locals {
  # Hosts 0 to 31 of each private subnet, the smallest single CIDR block holding every
  # endpoint_host_offsets value. Changing it replaces the reservation.
  reservation_prefix_length = 27
}

# Explicit reservation. AWS never hands these addresses to a node, a pod prefix, or another ENI.
resource "aws_ec2_subnet_cidr_reservation" "endpoints" {
  count = length(var.private_subnets)

  subnet_id        = var.private_subnets[count.index]
  cidr_block       = "${cidrhost(var.private_subnets_cidr_blocks[count.index], 0)}/${local.reservation_prefix_length}"
  reservation_type = "explicit"
  description      = "Pinned interface VPC endpoint IPs"

  lifecycle {
    precondition {
      condition = alltrue([
        for offset in values(var.endpoint_host_offsets) : offset < pow(2, 32 - local.reservation_prefix_length)
      ])
      error_message = "Every endpoint_host_offsets value must fall inside the reserved /${local.reservation_prefix_length}."
    }
  }
}
