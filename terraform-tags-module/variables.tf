# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "project" {
  description = "Name of the project"
  type        = string
}
variable "module" {
  description = "Name of the module"
  type        = string
}
variable "environment" {
  description = "Name of the environment"
  type        = string
}
variable "tags" {
  default     = {}
  description = "Additional tags. Overwrite module-generated tags"
  type        = map(string)
}