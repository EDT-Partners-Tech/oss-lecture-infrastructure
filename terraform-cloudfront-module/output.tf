# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "s3_bucket_arn" {
  value = aws_s3_bucket.website.arn
}
output "s3_bucket_id" {
  value = aws_s3_bucket.website.id
}
output "s3_bucket_domain_name" {
  value = aws_s3_bucket.website.bucket_domain_name
}
output "s3_bucket_region" {
  value = aws_s3_bucket.website.region
}
output "s3_hosted_zone_id" {
  value = aws_s3_bucket.website.hosted_zone_id
}
output "aws_route53_record_cloudfront" {
  description = "The FQDNs of the CloudFront alias records"
  value = [
    for r in aws_route53_record.cloudfront_alias_records :
    r.name
  ]
}
