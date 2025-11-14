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
variable "subnets" {
  type = string
}
variable "sec_group" {
  type = string
}
variable "route53_domain" {
  type = string
}
variable "hosted_zone_id" {
  type    = string
  default = ""
}
variable "acm_certificate" {
  type = string
}
variable "lambda_execution_role" {
  type = string
}
variable "lambda_layers" {}
variable "lambda_handler" {}
variable "lambda_runtime" {}
variable "lambda_timeout" {}
variable "lambda_memory_size" {}
variable "lambda_env" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}
