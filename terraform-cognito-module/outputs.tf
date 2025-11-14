# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "userpool_id" {
  value       = aws_cognito_user_pool.main.id
  description = "User Pool Id for Cognito Pool"
}
output "app_client_id" {
  value       = aws_cognito_user_pool_client.pool_client.id
  description = "Appclient Id for Cognito Pool"
}

