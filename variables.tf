# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "aws_region" {
  type = string
}
variable "project" {
  type = string
}
variable "vpc_range" {
  type = string
}
variable "vpc_range_public_1a" {
  type = string
}
variable "vpc_range_public_1b" {
  type = string
}
variable "vpc_range_private_1a" {
  type = string
}
variable "vpc_range_private_1b" {
  type = string
}
variable "environment" {
  type = string
}
variable "route53_domain" {
  type = string
}
variable "create_zone" {
  type = bool
}
variable "create_certs" {
  type = bool
}
variable "enable_root_domain" {
  description = "Enables Root domain to be used for the frontend"
  type        = bool
  default     = false
}
variable "secrets_uuid" {
  type = string
}
variable "api_key_expires" {
  type = string # RFC3339
  # example: "2026-11-12T16:00:00Z"
}