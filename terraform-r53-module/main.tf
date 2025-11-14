# © [2025] EDT&Partners. Licensed under CC BY 4.0.
# Provider for us-east-1 (global resources like CloudFront Certificates)
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_route53_zone" "existing" {
  count        = var.create_zone ? 0 : 1
  name         = var.domain
  private_zone = false
}

resource "aws_route53_zone" "new" {
  count = var.create_zone ? 1 : 0
  name  = var.domain
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.new[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

# Default region ACM cert resource or data
resource "aws_acm_certificate" "new" {
  count             = var.create_certs ? 1 : 0
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_acm_certificate" "existing" {
  count       = var.create_certs ? 0 : 1
  domain      = "*.${var.domain}"
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# ACM cert in us-east-1 region, resource or data source depending on create_certs
resource "aws_acm_certificate" "new_global" {
  provider          = aws.virginia
  count             = var.create_certs ? 1 : 0
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"

  subject_alternative_names = var.enable_root_domain ? [var.domain] : []

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_acm_certificate" "existing_global" {
  provider    = aws.virginia
  count       = var.create_certs ? 0 : 1
  domain      = "*.${var.domain}"
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}


resource "aws_route53_record" "cert_validation" {
  count = var.create_certs ? length(aws_acm_certificate.new[0].domain_validation_options) : 0

  zone_id = local.zone_id
  name    = tolist(aws_acm_certificate.new[0].domain_validation_options)[count.index].resource_record_name
  type    = tolist(aws_acm_certificate.new[0].domain_validation_options)[count.index].resource_record_type
  records = [tolist(aws_acm_certificate.new[0].domain_validation_options)[count.index].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "new" {
  count                   = var.create_certs ? 1 : 0
  certificate_arn         = aws_acm_certificate.new[0].arn
  validation_record_fqdns = aws_route53_record.cert_validation.*.fqdn
}

# Locals to select cert ARNs conditionally
locals {
  cert_arn        = var.create_certs ? aws_acm_certificate.new[0].arn : data.aws_acm_certificate.existing[0].arn
  cert_global_arn = var.create_certs ? aws_acm_certificate.new_global[0].arn : data.aws_acm_certificate.existing_global[0].arn
}

