# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "lambda_role" {
  value       = aws_iam_role.lambda_role.arn
  description = "LAMBDA ROLE ARN"
}

output "agent_role" {
  value = aws_iam_role.bedrock_agent.arn
}