# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "alb_tg_main" {
  value       = aws_lb_target_group.this.arn
  description = "TG for main"
}

output "ecs_service_name" {
  value       = aws_ecs_service.ecs_service.name
  description = "ECS Service name"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.td.arn
  description = "Task Definition ARN"
}

