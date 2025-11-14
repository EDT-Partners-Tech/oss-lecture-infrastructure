# © [2025] EDT&Partners. Licensed under CC BY 4.0.
data "aws_availability_zones" "available" {}

############ VPC ############
module "lecture_vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "=5.21"
  name            = "${var.project}-base"
  cidr            = var.vpc_range
  azs             = data.aws_availability_zones.available.names
  private_subnets = [var.vpc_range_private_1a, var.vpc_range_private_1b]
  public_subnets  = [var.vpc_range_public_1a, var.vpc_range_public_1b]

  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  enable_vpn_gateway                   = false
  enable_flow_log                      = false
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
}

############ ROUTE 53 ############

module "multiaccount_r53" {
  source             = "./terraform-r53-module"
  environment        = var.environment
  domain             = var.route53_domain
  create_zone        = var.create_zone
  create_certs       = var.create_certs
  enable_root_domain = var.enable_root_domain
}

module "github_identity_provider" {
  source  = "./terraform-identity-provider-module"
  project = var.project
}

############ Environment Buckets############

module "lecture_s3_fixed_buckets" {
  source          = "./terraform-s3-module"
  for_each        = { for idx, config in local.s3_config : idx => config }
  s3_name         = each.value.s3_name
  s3_block_public = each.value.s3_block_public
  project         = var.project
  module          = each.value.s3_name
  environment     = var.environment
  ssm_key         = each.value.ssm_key
  versioning      = "Enabled"
}

############ SECURITY GROUPS ############

module "lecture_security_groups" {
  source                      = "./terraform-security-groups-module"
  project                     = var.project
  environment                 = var.environment
  vpc_id                      = module.lecture_vpc.vpc_id
  private_subnets_cidr_blocks = [var.vpc_range]
}

############ SSM VARIABLES############

module "ssm_dynamic_variables" {
  source               = "cloudposse/ssm-parameter-store/aws"
  ignore_value_changes = "true"
  parameter_write      = local.json_dynamic_variables
}


module "cognito_idp" {
  source      = "./terraform-cognito-module"
  project     = var.project
  environment = var.environment
  region      = var.aws_region

}


############ RDS ############

module "rds_cluster" {
  source                      = "./terraform-rds-cluster"
  project                     = var.project
  vpc_id                      = module.lecture_vpc.vpc_id
  private_subnets_cidr_blocks = [var.vpc_range]
  private_subnets_ids         = module.lecture_vpc.private_subnets
  security_groups             = tolist([module.lecture_security_groups.rds_mysql_sg_id, module.lecture_security_groups.lambda_sg_id])
  database_name               = "lecture_core"
  allocated_storage           = "50"
  max_allocated_storage       = "100"
  storage_type                = "gp2"
  engine_version              = "16.6"
  instance_class              = "db.serverless"
  monitoring_interval         = 10
  backup_retention_period     = "5"
  backup_window               = "03:00-06:00"
  domain                      = var.route53_domain
  hosted_zone_id              = module.multiaccount_r53.zone_id
  secrets_uuid                = var.secrets_uuid
}

