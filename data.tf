# © [2025] EDT&Partners. Licensed under CC BY 4.0.
#data "aws_acm_certificate" "this" {
#  domain      = "*.${var.route53_domain}"
#  statuses    = ["ISSUED"]
#  types       = ["AMAZON_ISSUED"]
#  most_recent = true
#}

# For global region (us-east-1, e.g., CloudFront)
#data "aws_acm_certificate" "global" {
#  provider    = aws.virginia
#  domain      = "*.${var.route53_domain}"
#  statuses    = ["ISSUED"]
#  types       = ["AMAZON_ISSUED"]
#  most_recent = true
#}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_bedrock_foundation_models" "all" {}
