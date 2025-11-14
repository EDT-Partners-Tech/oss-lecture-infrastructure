# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "ecs_cluster_name" {
  value       = aws_ecs_cluster.ecs_cluster.name
  description = "ECS Cluster name"
}

