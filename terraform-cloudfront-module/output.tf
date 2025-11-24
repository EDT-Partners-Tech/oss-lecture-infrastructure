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
