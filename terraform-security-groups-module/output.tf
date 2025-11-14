# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}
output "rds_mysql_sg_id" {
  value = aws_security_group.rds_mysql_sg.id
}
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}
output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}