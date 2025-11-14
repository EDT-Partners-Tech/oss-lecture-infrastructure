# © [2025] EDT&Partners. Licensed under CC BY 4.0.
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