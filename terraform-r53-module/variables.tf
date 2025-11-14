# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "domain" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
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
