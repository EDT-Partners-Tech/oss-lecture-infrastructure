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
############ FRONTEND RESOURCES ############

module "lecture_cloudfront_frontends" {
  source             = "./terraform-cloudfront-module"
  for_each           = { for idx, config in local.cloudfront_configs : idx => config }
  environment        = var.environment
  project            = var.project
  module             = each.value.repository
  domain_alias       = each.value.domain_alias
  route53_domain     = var.route53_domain
  certificate_arn    = module.multiaccount_r53.cert_global_arn
  hosted_zone_id     = module.multiaccount_r53.zone_id
  enable_bucket_cors = each.value.enable_bucket_cors
  repository_name    = each.value.repository_name
  enable_root_domain = lookup(each.value, "enable_root_domain", false)

}

############ LAMBDA RESOURCES ############


resource "aws_s3_bucket" "lecture_lambda_functions_bucket" {
  bucket = "lecture-${var.environment}-lambda-deploy-${var.route53_domain}"
  tags = {
    environment = var.environment
    project     = var.project
  }
}

module "lambda_execution_role" {
  source  = "./terraform-iam-module"
  project = var.project

}

module "lambda_layer" {
  source   = "./terraform-lambda-layer-module"
  for_each = { for idx, config in local.lambda_layers : idx => config }
  filename = each.value.filename

}

module "lecture_lambda_functions" {
  source                = "./terraform-lambda-module"
  for_each              = { for idx, config in local.lambda_configs : idx => config }
  project               = var.project
  module                = each.value.repository
  environment           = var.environment
  lambda_execution_role = module.lambda_execution_role.lambda_role
  lambda_handler        = each.value.lambda_handler
  lambda_runtime        = lookup(each.value, "lambda_runtime", "nodejs18.x")
  lambda_timeout        = each.value.lambda_timeout
  lambda_memory_size    = each.value.lambda_memory_size
  subnets               = module.lecture_vpc.private_subnets[0]
  sec_group             = module.lecture_security_groups.lambda_sg_id
  route53_domain        = var.route53_domain
  acm_certificate       = ""
  hosted_zone_id        = module.multiaccount_r53.zone_id
  tags                  = {}
  lambda_env            = local.lambda_env
  lambda_layers = [
    for layer_instance in module.lambda_layer : layer_instance.arn
    if(
      each.value.repository == "textToSql" && can(regex("texttosql", layer_instance.arn))
      ) || (
      !can(regex("texttosql", layer_instance.arn))
    )
  ]

}

module "dynamodb" {
  source     = "./terraform-dynamodb-module"
  for_each   = { for idx, config in local.dynamodb_configs : idx => config }
  table_name = each.value.table_name
  tags       = {}

}

#######AWS ECS#######################

module "lecture_ecs_alb" {
  source                 = "./terraform-ecs-alb-module"
  project                = var.project
  module                 = "ecs-services"
  vpc_id                 = module.lecture_vpc.vpc_id
  security_groups        = tolist([module.lecture_security_groups.alb_sg_id])
  certificate_arn        = module.multiaccount_r53.cert_arn
  global_certificate_arn = module.multiaccount_r53.cert_global_arn
  subnet_public_ids      = module.lecture_vpc.public_subnets
  hosted_zone_id         = module.multiaccount_r53.zone_id
  domain_name            = var.route53_domain
  ecs_services           = [for config in local.ecs_config : "${config.name}.${var.route53_domain}"]

}

module "lecture_ecs_cluster" {
  source  = "./terraform-ecs-cluster-module"
  project = var.project
  module  = "lecture-ecs-cluster"
}

module "lecture_ecs_services" {
  source   = "./terraform-ecs-service-module"
  for_each = { for idx, config in local.ecs_config : idx => config }

  project             = var.project
  module              = each.value.name
  vpc_id              = module.lecture_vpc.vpc_id
  region              = var.aws_region
  port                = 80
  alb_dns_name        = module.lecture_ecs_alb.alb_dns_name
  alb_sg_name         = tolist([module.lecture_security_groups.alb_sg_id])
  domain_name         = var.route53_domain
  hosted_zone_id      = module.multiaccount_r53.zone_id
  health_check        = "/health"
  subnet_private_ids  = module.lecture_vpc.private_subnets
  security_groups     = tolist([module.lecture_security_groups.ecs_sg_id])
  cluster_name        = module.lecture_ecs_cluster.ecs_cluster_name
  listener_arn        = module.lecture_ecs_alb.listener_arn
  task_cpu            = each.value.task_cpu
  task_memory         = each.value.task_memory
  td_environment_vars = []
  asg_min_capacity    = each.value.asg_min_capacity
  asg_max_capacity    = each.value.asg_max_capacity
  db_connection_arn   = module.rds_cluster.lecture_database_connection_secret_arn
  repository_name     = each.value.repository_name

}

#############STEP FUNCTIONS################

module "lecture_state_machine" {
  source = "./terraform-state-machine-module"

  for_each = { for sm in local.state_machines : sm.name => sm }

  name        = each.value.name
  description = each.value.description
  lambda_arns = each.value.lambda_arns
  aws_region  = var.aws_region
}

#############BEDROCK AGENTS################

module "bedrock_agents" {
  for_each = local.agents
  source   = "./terraform-bedrock-module"

  project                 = var.project
  agent_name              = each.value.agent_name
  agent_role              = module.lambda_execution_role.agent_role
  foundation_model        = each.value.foundation_model
  action_groups           = each.value.action_groups
  agent_resource_role_arn = module.lambda_execution_role.agent_role
}
#############Athena STD################

module "athena" {
  source  = "./terraform-athena-module"
  project = var.project
  region  = var.aws_region
}


module "appsync" {
  source          = "./terraform-appsync-module"
  project         = var.project
  domain          = var.route53_domain
  hosted_zone_id  = module.multiaccount_r53.zone_id
  certificate_arn = module.multiaccount_r53.cert_global_arn
  region          = var.aws_region
  api_key_expires = var.api_key_expires
}

module "secrets" {
  source = "./terraform-secrets-manager-module"

  for_each     = local.secrets_dynamic_variables
  name         = each.value.name
  type         = each.value.type
  custom_value = each.value.custom_value
  #rotation    = each.value.rotation
  secrets_uuid = var.secrets_uuid
}