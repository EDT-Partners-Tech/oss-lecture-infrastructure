# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "project" {
  type = string
}
variable "module" {
  type = string
}
variable "environment" {
  type = string
}
variable "route53_domain" {
  type = string
}
variable "certificate_arn" {
  type = string
}
variable "hosted_zone_id" {
  type = string
}
variable "domain_alias" {
  type = list(string)
}
variable "enable_bucket_cors" {
  type    = string
  default = false
}
variable "repository_name" {
  description = "Github Repository"
  type        = string
}
variable "enable_root_domain" {
  description = "Enables Root domain to be used for the frontend"
  type        = bool
  default     = false
}
