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
  type = string
}

variable "description" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "lambda_arns" {
  type = object({
    create_collection  = string
    create_index       = string
    create_kb          = string
    create_data_source = string
  })
  default = {
    create_collection  = ""
    create_index       = ""
    create_kb          = ""
    create_data_source = ""
  }
}