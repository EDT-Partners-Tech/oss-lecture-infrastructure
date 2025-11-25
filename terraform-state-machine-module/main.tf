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
resource "aws_iam_role" "stepfunction_role" {
  name = "StepFunctions_IAM_ROLE_${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_invoke" {
  name = "LambdaInvokePolicy_${var.name}"
  role = aws_iam_role.stepfunction_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = aws_iam_role.stepfunction_role.arn
  type     = "STANDARD"

  definition = templatefile("${path.module}/${var.name}.json", {
    lambda_arns = var.lambda_arns
    description = var.description
  })
}
