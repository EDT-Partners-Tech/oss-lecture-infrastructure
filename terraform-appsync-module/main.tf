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
# Get current AWS region
data "aws_region" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# IAM role for CloudWatch logging
resource "awscc_iam_role" "appsync_logs" {
  role_name = "appsync-logs-role"
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })

  policies = [
    {
      policy_name = "appsync-cloudwatch-logs"
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            Resource = [
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/appsync/*:*"
            ]
          }
        ]
      })
    }
  ]
}

# AppSync API
resource "awscc_appsync_api" "this" {
  name = "${var.project}-appsync"

  event_config = {
    log_config = {
      cloudwatch_logs_role_arn = awscc_iam_role.appsync_logs.arn
      log_level                = "INFO"
    }
    auth_providers = [
      {
        auth_type = "API_KEY"
      }
    ]
    connection_auth_modes = [
      {
        auth_type = "API_KEY"
      }
    ]
    default_publish_auth_modes = [
      {
        auth_type = "API_KEY"
      }
    ]
    default_subscribe_auth_modes = [
      {
        auth_type = "API_KEY"
      }
    ]
  }

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

locals {
  appsync_api_id = regex("apis\\/([^:\\/]+)", awscc_appsync_api.this.id)
}

# Output the ID if needed
output "appsync_api_id" {
  value = local.appsync_api_id[0]
}

# Create API Key
resource "aws_appsync_api_key" "this" {
  api_id      = local.appsync_api_id[0]
  description = "Appsync Key"
  expires     = var.api_key_expires #timeadd(timestamp(), "8760h") # 365 days * 24 hours
}


resource "aws_appsync_domain_name" "this" {

  domain_name     = "appsync.${var.domain}"
  description     = ""
  certificate_arn = var.certificate_arn
}

resource "aws_appsync_domain_name_api_association" "this" {

  api_id      = local.appsync_api_id[0]
  domain_name = aws_appsync_domain_name.this.domain_name
}


resource "aws_route53_record" "appsync" {
  zone_id = var.hosted_zone_id
  name    = aws_appsync_domain_name.this.domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_appsync_domain_name.this.appsync_domain_name]
}

module "ssm_dynamic_variables" {
  source               = "cloudposse/ssm-parameter-store/aws"
  ignore_value_changes = true
  parameter_write = [
    {
      name        = "/lecture/global/AWS_APP_SYNC_ENDPOINT"
      value       = "https://${aws_appsync_domain_name.this.domain_name}"
      type        = "String"
      overwrite   = true
      description = "Custom Domain Endpoint For Appsync"
    },
    {
      name        = "/lecture/global/AWS_APP_SYNC_API_KEY"
      value       = aws_appsync_api_key.this.key
      type        = "String"
      overwrite   = true
      description = "APYKEY for Appsync"
    }
  ]
}


resource "awscc_appsync_channel_namespace" "this" {
  name   = "lecture-appsync-namespace"
  api_id = local.appsync_api_id[0]

  # Example of publish and subscribe auth modes
  publish_auth_modes = [{
    auth_type = "API_KEY"
  }]

  subscribe_auth_modes = [{
    auth_type = "API_KEY"
  }]

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}
