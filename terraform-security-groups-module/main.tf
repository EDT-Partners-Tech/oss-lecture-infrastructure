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
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project}-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "rds_mysql_sg" {
  name        = "${var.project}-rds-sg"
  description = "Allow Traffic from Private Subnets to RDS MYSQL"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id
}


resource "aws_security_group" "ec2_sg" {
  name        = "${var.project}-ec2-sg"
  description = "Security Group for running tasks on EC2 instance"
  vpc_id      = var.vpc_id

}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project}-ecs-sg"
  description = "Security Group for running tasks on ECS cluster"
  vpc_id      = var.vpc_id

}


############################ RULES ####################################
##ALB RULES###
resource "aws_security_group_rule" "alb_sg_egress" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_sg_ingress" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_sg_ingress_https" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_sg_ingress_http" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

############################

##LAMBDAS RULES###
resource "aws_security_group_rule" "lambda_egress" {
  security_group_id = aws_security_group.lambda_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp" # Allow all traffic
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lambda_to_rds" {
  security_group_id        = aws_security_group.lambda_sg.id
  type                     = "egress"
  from_port                = 5432 # Assuming your RDS is using MySQL
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_mysql_sg.id
}

############################

##RDS RULES###

resource "aws_security_group_rule" "rds_egress" {
  security_group_id = aws_security_group.rds_mysql_sg.id
  type              = "egress"
  from_port         = 0 # Assuming your RDS is using MySQL
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rds_internal_ingress" {
  security_group_id = aws_security_group.rds_mysql_sg.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "-1" # Allow all traffic
  cidr_blocks       = var.private_subnets_cidr_blocks
}

############################


##ECS RULES###


resource "aws_security_group_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs_sg.id
  type              = "egress"
  from_port         = 0 # Assuming your RDS is using MySQL
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_ingress" {
  security_group_id = aws_security_group.ecs_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp" # Allow all traffic
  # cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = aws_security_group.alb_sg.id

}

###