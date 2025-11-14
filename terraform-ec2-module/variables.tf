# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "instance_type" {
  description = "Instance type for the bastion host"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for SSH"
}

variable "public_subnet_id" {
  description = "The public subnet ID where the bastion host will be deployed"
}

variable "security_group_id" {
  description = "Security group ID to attach to the bastion host"
}

variable "instance_name" {
  description = "Name for the bastion VM"
}
