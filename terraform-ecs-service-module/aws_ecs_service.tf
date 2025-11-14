# © [2025] EDT&Partners. Licensed under CC BY 4.0.
#
# SG for ECS Service
#
resource "aws_security_group" "ecs" {
  name        = "${var.module}-ecs-sg"
  description = "Security Group for running tasks on ECS cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "ecs_service" {
  name                               = "${var.module}-ecs-service"
  cluster                            = var.cluster_name
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  propagate_tags                     = "TASK_DEFINITION"
  scheduling_strategy                = "REPLICA"
  force_new_deployment               = true

  network_configuration {
    subnets          = var.subnet_private_ids
    security_groups  = tolist([aws_security_group.ecs.id])
    assign_public_ip = false
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = var.module
    container_port   = var.port
    target_group_arn = aws_lb_target_group.this.arn
  }

  task_definition = aws_ecs_task_definition.td.arn

  lifecycle {
    ignore_changes = [desired_count]
  }
  depends_on = [aws_lb_target_group.this, aws_lb_listener_rule.rule]

}

#
# Cloudwatch log group
#

resource "aws_cloudwatch_log_group" "ecs_cf_log_group" {
  name              = "/${var.project}/${var.module}"
  retention_in_days = 7

}

#
# Load Balancer: Target Group
#

resource "aws_lb_target_group" "this" {
  name             = var.module
  port             = var.port
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  target_type      = "ip"
  slow_start       = "30"
  vpc_id           = var.vpc_id

  health_check {
    interval            = 30
    protocol            = "HTTP"
    path                = var.health_check
    matcher             = "200-499"
    healthy_threshold   = 2
    unhealthy_threshold = 6
  }
}

#
# Load Balancer: Listener Rules
#

resource "aws_lb_listener_rule" "rule" {
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = ["${var.module}.${var.domain_name}", "${var.module}-alb.${var.domain_name}"]
    }
  }
}


resource "aws_route53_record" "ecs-alb" {
  zone_id = var.hosted_zone_id
  name    = "${var.module}-alb.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.alb_dns_name]
}


