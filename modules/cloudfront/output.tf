output "cf_domain_name" {
  value = aws_cloudfront_distribution.dte_cloud_front.domain_name
}

output "cf_hosted_zone_id" {
  value = aws_cloudfront_distribution.dte_cloud_front.hosted_zone_id
}

output "cf_distribution_id" {
  value = aws_cloudfront_distribution.dte_cloud_front.id
}

output "s3_oai_id" {
  value = aws_cloudfront_origin_access_identity.s3_oai.iam_arn
}