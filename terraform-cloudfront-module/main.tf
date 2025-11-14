# © [2025] EDT&Partners. Licensed under CC BY 4.0.
locals {
  domain_aliases_with_domain = concat(
    [for alias in var.domain_alias : "${alias}.${var.route53_domain}"],
    var.enable_root_domain ? [var.route53_domain] : []
  )
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_distribution.iam_arn]
    }
  }
}

data "aws_cloudfront_origin_request_policy" "CorsOrginRequestPolicy" {
  name = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "CacheOptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_response_headers_policy" "CorsWithPreflightAndSCP" {
  name = "Managed-CORS-with-preflight-and-SecurityHeadersPolicy"
}


#
# AWS S3
#

resource "aws_s3_bucket" "website" {
  bucket = "${var.module}-${var.environment}"
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_cors_configuration" "s3_cors_configuration" {
  count  = var.enable_bucket_cors ? 1 : 0
  bucket = aws_s3_bucket.website.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["*"]
  }
}
#
# AWS CLOUDFRONT
#

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_distribution.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloudfront Distribution for ${var.module}"
  default_root_object = "index.html"
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  aliases = local.domain_aliases_with_domain

  default_cache_behavior {
    target_origin_id = aws_s3_bucket.website.id
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]

    viewer_protocol_policy     = "redirect-to-https"
    min_ttl                    = 0
    cache_policy_id            = data.aws_cloudfront_cache_policy.CacheOptimized.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.CorsOrginRequestPolicy.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.CorsWithPreflightAndSCP.id
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "s3_distribution" {
  comment = "S3 identity for ${var.module}"
}


#
# AWS Hosted Zones
#

resource "aws_route53_record" "cloudfront_alias_records" {
  for_each = toset(local.domain_aliases_with_domain)

  zone_id = var.hosted_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}