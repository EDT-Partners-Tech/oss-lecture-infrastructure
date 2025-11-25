# 
# Copyright 2025 EDT&Partners
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
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

