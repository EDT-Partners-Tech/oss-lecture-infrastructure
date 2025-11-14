# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "name" {
  description = "Name of the secret"
  type        = string
}

variable "type" {
  description = "Type of the secret value: hex, base64, or custom"
  type        = string
  validation {
    condition     = contains(["hex", "base64", "custom"], var.type)
    error_message = "Type must be one of: hex, base64, custom"
  }
}

variable "custom_value" {
  description = "Custom secret value if type is 'custom'"
  type        = string
  default     = null
}

variable "rotation" {
  description = "Enable rotation for this secret"
  type        = bool
  default     = false
}

variable "secrets_uuid" {
  type = string
}