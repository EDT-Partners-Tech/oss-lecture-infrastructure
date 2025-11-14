# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "project" {
  description = "Name of the project"
  type        = string
}
variable "region" {
  description = "Name of the region"
  type        = string
}

variable "domain" {
  description = "Internal domain name for project"
  type        = string
}

variable "hosted_zone_id" {
  description = "Hosted zone ID"
  type        = string
}


variable "certificate_arn" {
  description = "certificate_arn"
  type        = string
}

variable "api_key_expires" {
  type = string # RFC3339
  # example: "2026-11-12T16:00:00Z"
}