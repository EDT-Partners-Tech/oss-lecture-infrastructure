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