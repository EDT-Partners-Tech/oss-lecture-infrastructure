# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "project" {
  type = string
}
variable "environment" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "private_subnets_cidr_blocks" {
  type = list(string)
}
