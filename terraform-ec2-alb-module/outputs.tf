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
output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.alb.arn
}

output "alb_id" {
  description = "The ID of the ALB"
  value       = aws_lb.alb.id
}

output "alb_dns_name" {
  description = "The DNS Name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_name" {
  description = "The name of the ALB"
  value       = aws_lb.alb.name
}

output "listener_arn" {
  description = "The ARN of the HTTPs Listener"
  value       = aws_lb_listener.https_listener.arn
}

output "aws_route53_record_alb" {
  description = "The ARN of the HTTPs Listener"
  value       = aws_route53_record.ec2-alb.records
}

output "aws_route53_record_cloudfront" {
  description = "The ARN of the HTTPs Listener"
  value       = aws_route53_record.cloudfront[*].records

}