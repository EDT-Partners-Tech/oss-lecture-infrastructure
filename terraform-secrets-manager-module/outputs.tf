# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}