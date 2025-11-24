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
variable "instance_type" {
  description = "Instance type for the bastion host"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for SSH"
}

variable "public_subnet_id" {
  description = "The public subnet ID where the bastion host will be deployed"
}

variable "security_group_id" {
  description = "Security group ID to attach to the bastion host"
}

variable "instance_name" {
  description = "Name for the bastion VM"
}
