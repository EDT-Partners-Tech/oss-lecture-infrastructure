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
resource "aws_s3_bucket" "this" {
  bucket = var.s3_name
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.s3_block_public
  block_public_policy     = var.s3_block_public
  ignore_public_acls      = var.s3_block_public
  restrict_public_buckets = var.s3_block_public
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  count      = var.s3_block_public ? 0 : 1
  depends_on = [aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.this.id
  acl        = "public-read"
}


resource "aws_s3_bucket_versioning" "bucketVersioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning
  }
}


locals {
  modules_env = {
    "${var.ssm_key}" = aws_s3_bucket.this.bucket
  }
  module_variables = flatten([
    for name, value in local.modules_env : {
      name        = "/lecture/global/${name}"
      value       = "${value}"
      type        = "String"
      overwrite   = "true"
      description = ""
    }
  ])
}

module "ssm_dynamic_variables" {
  source               = "cloudposse/ssm-parameter-store/aws"
  ignore_value_changes = "true"
  parameter_write      = local.module_variables
}
