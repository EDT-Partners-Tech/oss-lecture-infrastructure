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

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

variable "private_subnets_cidr_blocks" {
  description = "Private subnets cidr blocks"
  type        = list(string)
}

variable "private_subnets_ids" {
  description = "Private subnets ids"
  type        = list(string)
}

variable "security_groups" {
  description = "Security Groups ids"
  type        = list(string)
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "allocated_storage" {
  description = "Initial storage"
  type        = number
}

variable "max_allocated_storage" {
  description = "Maximum amount of storage that can be allocated with Autoscaling"
  type        = number
}

variable "storage_type" {
  description = "Storage type: io1, gp2 or standard (magnetic)"
  type        = string
  default     = "gp2"
}

variable "parameter_group_name" {
  description = "The parameter group name for MySQL"
  type        = string
  default     = "default.aurora-mysql8.0"
}
variable "engine_version" {
  description = "MySQL Aurora version"
  type        = string
}

variable "instance_class" {
  description = "The instance class for the MySQL DB"
  type        = string
}

variable "kms_key_id" {
  description = "KMS Key for encryption at rest"
  type        = string
  default     = ""
}


variable "monitoring_interval" {
  description = "The interval in seconds to check the health of the DB instance"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "Number of backups to retain"
  type        = number
  default     = 5
}

variable "backup_window" {
  description = "Available hours to execute backups"
  type        = string
  default     = "03:00-06:00"
}

variable "domain" {
  description = "Internal domain name for ElasticSearch"
  type        = string
}

variable "hosted_zone_id" {
  description = "Hosted zone ID"
  type        = string
}

variable "secrets_uuid" {
  type = string
}