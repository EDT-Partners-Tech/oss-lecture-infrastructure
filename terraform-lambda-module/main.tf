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
#
# AWS Lambda
#
resource "aws_lambda_function" "this" {
  filename      = "lambda_function.zip"
  function_name = var.module
  role          = var.lambda_execution_role
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  layers        = var.lambda_layers

  environment {
    variables = var.lambda_env
  }

  vpc_config {
    security_group_ids = [
      var.sec_group
    ]
    subnet_ids = [
      var.subnets
    ]
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      filename,
      environment,
      handler,
      timeout,
      memory_size,
      description
    ]
  }
}

### Retry event 0 Setup for lambdas
resource "aws_lambda_function_event_invoke_config" "this" {
  function_name                = aws_lambda_function.this.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

}

#
# AWS CloudWatchLogs
#

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = "7"
  tags              = var.tags
}

###########Resourse based permissions 

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_lambda_permission" "allow_bedrock_invoke" {
  statement_id  = "lambda_invoke_from_agent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "bedrock.amazonaws.com"

  source_arn = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"
}