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
  description = "Project name"
  type        = string
}

variable "domain_name" {
  description = "The domain name to create Alias."
  type        = string
}


variable "port" {
  description = "The of the service."
  type        = string
}


variable "module" {
  description = "The module that created the resources."
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

variable "subnet_public_ids" {
  description = "List of the Public Subnet IDs."
  type        = list(any)
}

variable "hosted_zone_id" {
  description = "hosted_zone_id "
  type        = string
}

variable "ec2_services" {
  description = "ecs_services to use for cloudfront "
  type        = list(string)
}

variable "instance_id" {
  description = "instance id "
  type        = string
}

variable "health_check" {
  description = "path of the healthcheck "
  type        = string
}
