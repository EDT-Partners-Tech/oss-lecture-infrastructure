# © [2025] EDT&Partners. Licensed under CC BY 4.0.
output "s3_bucket_id" {
  value = aws_s3_bucket.this.id
}
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}