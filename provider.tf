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

variable "available_buckets" {
  default = {
    prod = "lecture-prod-terraform-state-prod"
  }
}

terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    key    = "lecture-terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      environment = var.environment
      owner       = "${var.project}-terraform"
      project     = var.project
    }
  }

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.98.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.45.0"
    }

  }
}

# Provider for us-east-1 (global resources)
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}



provider "awscc" {
  region = var.aws_region
}