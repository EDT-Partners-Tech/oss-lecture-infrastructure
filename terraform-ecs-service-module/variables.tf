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

variable "module" {
  type = string
}

variable "region" {
  description = "Project region"
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  description = "hosted_zone_id "
  type        = string
}

variable "alb_dns_name" {
  description = "The dnsNAME of the ALB"
  type        = string
}

variable "alb_sg_name" {
  description = "The Security of the ALB"
}


variable "port" {
  description = "The default application port"
  type        = number
}

variable "health_check" {
  description = "Path for health check verification"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID of current environment infrastructure"
  type        = string
}

variable "subnet_private_ids" {
  description = "Private subnet ids"
  type        = list(string)
}
variable "security_groups" {
  description = "Security Groups ids"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the cluster to attach the service"
  type        = string
}

variable "listener_arn" {
  description = "The ARN of the Listener of the ALB"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name to create Alias."
  type        = string
}

variable "task_cpu" {
  description = "Amount of CPU to assign to the task"
  type        = string
}

variable "task_memory" {
  description = "Amount of Memory to assign to the task"
  type        = string
}

variable "td_environment_vars" {
  description = "Task Definition env variables"
  type        = list(map(string))
}


variable "asg_min_capacity" {
  description = "Minimum capacity for an ECS task"
  type        = number
}

variable "asg_max_capacity" {
  description = "Maximum capacity for an ECS task"
  type        = number
}

variable "db_connection_arn" {
  description = "Secret Manager Database connection arn"
  type        = string
}

variable "repository_name" {
  description = "Github Repository"
  type        = string
}


