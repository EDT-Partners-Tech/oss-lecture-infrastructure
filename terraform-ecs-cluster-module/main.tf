# © [2025] EDT&Partners. Licensed under CC BY 4.0.
#
# ECS Cluster
#

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.module
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = local.common_tags
}