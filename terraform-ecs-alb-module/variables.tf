# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "project" {
  description = "Project name"
  type        = string
}
variable "module" {
  description = "Module name"
  type        = string
}

variable "domain_name" {
  description = "The domain name to create Alias."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "security_groups" {
  description = "Security Groups ids"
  type        = list(string)
}


variable "certificate_arn" {
  description = "The ACM Arn for the HTTPs listener"
  type        = string
}

variable "global_certificate_arn" {
  description = "The ACM Arn for the HTTPs listener"
  type        = string
}
variable "subnet_public_ids" {
  description = "List of the Public Subnet IDs."
  type        = list(any)
}

variable "hosted_zone_id" {
  description = "hosted_zone_id "
  type        = string
}

variable "ecs_services" {
  description = "ecs_services to use for cloudfront "
  type        = list(string)
}
