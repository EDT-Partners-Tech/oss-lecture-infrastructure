# © [2025] EDT&Partners. Licensed under CC BY 4.0.
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
