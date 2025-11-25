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
