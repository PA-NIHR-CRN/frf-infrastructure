provider "aws" {
  region = "us-east-1"
}

#data "aws_acm_certificate" "issued" {
#  domain   = "*.${var.domain_name}"
#  statuses = ["ISSUED"]
#}

data "aws_cloudfront_cache_policy" "policy" {
  name = "Managed-CachingOptimized"
  # not compatible with tags
}
