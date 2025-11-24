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
resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = "lambda_files/${var.filename}.zip"
  source_code_hash    = filebase64sha256("lambda_files/${var.filename}.zip")
  layer_name          = var.filename
  compatible_runtimes = ["python3.12", "python3.13"]
  skip_destroy        = true
}