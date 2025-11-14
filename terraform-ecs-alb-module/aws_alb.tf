# © [2025] EDT&Partners. Licensed under CC BY 4.0.
#
# Load Balancer
#

resource "aws_lb" "alb" {
  name                       = "lecture-${var.module}-alb"
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = var.security_groups
  ip_address_type            = "ipv4"
  subnets                    = toset(var.subnet_public_ids)
  preserve_host_header       = true
  enable_deletion_protection = false
  idle_timeout               = 900
}

#
# Load Balancer: HTTP Listener
#

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#
# Load Balancer: HTTPS Listener
#

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn                                               = aws_lb.alb.arn
  port                                                            = "443"
  protocol                                                        = "HTTPS"
  certificate_arn                                                 = var.certificate_arn
  ssl_policy                                                      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  routing_http_response_access_control_allow_origin_header_value  = "*"
  routing_http_response_access_control_allow_headers_header_value = "*"
  routing_http_response_access_control_allow_methods_header_value = "*"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Nothing."
      status_code  = "200"

    }
  }

}
#
# CloudFront Distribution
#
# Use dynamic ARNs for managed policies

data "aws_cloudfront_cache_policy" "cdn_managed_caching_disabled_cache_policy" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "cdn_managed_all_viewer_origin_request_policy" {
  name = "Managed-AllViewer"
}
data "aws_cloudfront_response_headers_policy" "managed_cors_with_preflight" {
  name = "Managed-CORS-With-Preflight"
}


#resource "aws_cloudfront_distribution" "cdn" {
#  origin {
#    domain_name = aws_lb.alb.dns_name
#    origin_id   = "${var.project}-${var.module}-alb"
#    custom_origin_config {
#      http_port              = 80
#      https_port             = 443
#      origin_protocol_policy = "https-only" # Adjust this according to your ALB configuration
#      origin_ssl_protocols   = ["TLSv1.2"]  # Adjust this according to your ALB configuration
#    }
#  }
#  comment = "Cloudfront Distribution for ${var.module}"
#  enabled = true
#  default_cache_behavior {
#    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#    cached_methods   = ["GET", "HEAD"]
#    target_origin_id = "${var.project}-${var.module}-alb"
#
#    cache_policy_id            = data.aws_cloudfront_cache_policy.cdn_managed_caching_disabled_cache_policy.id
#    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.cdn_managed_all_viewer_origin_request_policy.id
#    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.managed_cors_with_preflight.id
#
#    viewer_protocol_policy = "redirect-to-https"
#
#  }
#
#  # Add more cache behaviors if needed
#  ordered_cache_behavior {
#    path_pattern               = "/*"
#    allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#    cached_methods             = ["GET", "HEAD"]
#    target_origin_id           = "${var.project}-${var.module}-alb"
#    compress                   = true
#    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.managed_cors_with_preflight.id
#
#    # Specify legacy cache settings
#    viewer_protocol_policy = "redirect-to-https"
#    min_ttl                = 60
#    default_ttl            = 60
#    max_ttl                = 60
#
#    # Whitelist headers
#    forwarded_values {
#      query_string = true
#      headers      = ["Referer", "Host", "Authorization", "authorization"]
#      cookies {
#        forward = "all"
#      }
#
#    }
#  }
#
#  # Viewer Certificate
#  viewer_certificate {
#    acm_certificate_arn = var.global_certificate_arn
#    ssl_support_method  = "sni-only"
#  }
#  restrictions {
#    geo_restriction {
#      restriction_type = "none"
#    }
#  }
#  # Additional settings like logging, restrictions, etc. can be added here
#
#
#
#  aliases = var.ecs_services
#
#}




#
# AWS Hosted Zones
#

resource "aws_route53_record" "ecs-alb" {
  zone_id = var.hosted_zone_id
  name    = "${var.module}-alb.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.alb.dns_name]
}

resource "aws_route53_record" "cloudfront" {
  count   = length(var.ecs_services)
  zone_id = var.hosted_zone_id
  name    = var.ecs_services[count.index]
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.alb.dns_name]
}

