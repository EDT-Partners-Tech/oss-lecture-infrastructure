# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}
output "lecture_database_connection_secret_arn" {
  description = "ARN of the secret that contains the database connection info"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}