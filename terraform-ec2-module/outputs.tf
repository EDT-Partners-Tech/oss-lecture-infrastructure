# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "instance_id" {
  description = "The ARN of the ALB"
  value       = aws_instance.ec2_host.id
}