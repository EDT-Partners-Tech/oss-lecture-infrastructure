# 
# Copyright 2025 EDT&Partners
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
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