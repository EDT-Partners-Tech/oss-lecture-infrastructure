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
