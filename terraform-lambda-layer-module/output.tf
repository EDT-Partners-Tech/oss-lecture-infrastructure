# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "arn" {
  value       = aws_lambda_layer_version.lambda_layer.arn
  description = "Lambda Layer ARN"
}
