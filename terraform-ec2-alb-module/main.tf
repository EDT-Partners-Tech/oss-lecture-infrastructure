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
# Load Balancer
#

resource "aws_lb" "alb" {
  name                       = substr("${var.module}-alb", 0, 32)
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = var.security_groups
  ip_address_type            = "ipv4"
  subnets                    = toset(var.subnet_public_ids)
  preserve_host_header       = true
  enable_deletion_protection = false
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
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.ec2_tg.arn
      }
    }
  }
}

#
# Load Balancer: Target Group (EC2)
#

resource "aws_lb_target_group" "ec2_tg" {
  name             = "${var.module}-target-group"
  port             = var.port
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  target_type      = "instance"
  vpc_id           = var.vpc_id
  health_check {
    interval            = 30
    protocol            = "HTTP"
    path                = var.health_check
    matcher             = "200,301"
    healthy_threshold   = 2
    unhealthy_threshold = 6
  }
}

#
# EC2 Instance Target Group Attachment
#

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.ec2_tg.arn
  target_id        = var.instance_id
  port             = var.port
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

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = "${var.module}-alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only" # Adjust this according to your ALB configuration
      origin_ssl_protocols   = ["TLSv1.2"]  # Adjust this according to your ALB configuration
    }
  }
  comment = "Cloudfront Distribution for ${var.module}"
  enabled = true
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project}-${var.module}-alb"

    cache_policy_id          = data.aws_cloudfront_cache_policy.cdn_managed_caching_disabled_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cdn_managed_all_viewer_origin_request_policy.id

    viewer_protocol_policy = "redirect-to-https"
  }

  # Add more cache behaviors if needed
  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.module}-alb"
    compress         = true

    # Specify legacy cache settings
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    # Whitelist headers
    forwarded_values {
      query_string = true
      headers      = ["Origin", "Host", "Authorization", "authorization"]
      cookies {
        forward = "all"
      }
    }
  }

  # Viewer Certificate
  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  # Additional settings like logging, restrictions, etc. can be added here

  aliases = var.ec2_services
}

#
# AWS Hosted Zones
#

resource "aws_route53_record" "ec2-alb" {
  zone_id = var.hosted_zone_id
  name    = "${var.module}-alb.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.alb.dns_name]
}

resource "aws_route53_record" "cloudfront" {
  count   = length(var.ec2_services)
  zone_id = var.hosted_zone_id
  name    = var.ec2_services[count.index]
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.cdn.domain_name]
}
