resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "DTE ${var.env} S3 OAI for allowing Cloudfront to access Static Content S3 Bucket"
}
