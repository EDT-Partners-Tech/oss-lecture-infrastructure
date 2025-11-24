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

#
# DB Subnet Group
#
resource "aws_db_subnet_group" "db_postgres_subnet_group" {
  name       = "${var.project}-rds-postgres-db-subnet-group"
  subnet_ids = var.private_subnets_ids
}

#
# Standalone RDS PostgreSQL Instance
#
resource "random_password" "rds_password" {
  length  = 16
  special = false
}


############ STORE SECRETS
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "/lecture/global/DATABASE_SECRETS/${var.secrets_uuid}"
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = "postgresadmin"
    password = random_password.rds_password.result
    host     = aws_rds_cluster.aurora_cluster.endpoint
    dbname   = "lecture_core"
    port     = 5432
    engine   = "postgres"
  })
}
#
# Aurora Serverless v2 Cluster
#
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = "${var.project}-aurora-cluster"
  engine                 = "aurora-postgresql"
  engine_version         = var.engine_version
  database_name          = var.database_name
  master_username        = "postgresadmin"
  master_password        = random_password.rds_password.result
  db_subnet_group_name   = aws_db_subnet_group.db_postgres_subnet_group.name
  vpc_security_group_ids = var.security_groups
  storage_encrypted      = true
  #snapshot_identifier    = "arn:aws:rds:eu-central-1:781517218456:snapshot:test-custom-key" #DONT DELETE THIS SNAPSHOT NAME NOR THE COMMENT EVEN IF GODS ASK YOU TO
  backup_retention_period = var.backup_retention_period
  enable_http_endpoint    = true # for Data API if needed

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 4.0
  }

  tags = {
    Name = "${var.project}-aurora-cluster"
  }
}

#
# Aurora Cluster Instance (needed even in serverless v2)
#
resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier                 = "${var.project}-aurora-instance"
  cluster_identifier         = aws_rds_cluster.aurora_cluster.id
  instance_class             = "db.serverless"
  engine                     = aws_rds_cluster.aurora_cluster.engine
  engine_version             = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible        = false
  db_subnet_group_name       = aws_db_subnet_group.db_postgres_subnet_group.name
  auto_minor_version_upgrade = true
}




#
# AWS Route 53 Hosted Zone - PostgreSQL DNS
#
resource "aws_route53_record" "postgres" {
  zone_id = var.hosted_zone_id
  name    = "${var.project}-postgres.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_rds_cluster.aurora_cluster.endpoint]
}


locals {
  modules_env = {
    DATABASE_SECRET = aws_secretsmanager_secret.rds_credentials.arn
  }
  module_variables = flatten([
    for name, value in local.modules_env : {
      name        = "/lecture/global/${name}"
      value       = "${value}"
      type        = "String"
      overwrite   = "true"
      description = ""
    }
  ])
}

module "ssm_dynamic_variables" {
  source               = "cloudposse/ssm-parameter-store/aws"
  ignore_value_changes = "true"
  parameter_write      = local.module_variables
}
