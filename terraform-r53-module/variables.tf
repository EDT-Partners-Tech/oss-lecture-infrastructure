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
