resource "aws_cloudfront_distribution" "cloud_front" {
  origin {
    domain_name = var.lb_dns
    origin_id   = "alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # By default, show index.html file
  default_root_object = "index.html"
  enabled             = true

  # aliases = ["${var.dns_name}"]
  # If there is a 404, return index.html with a HTTP 200 Response
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "static-content"
    default_ttl      = 0
    min_ttl          = 0
    max_ttl          = 0
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.headers_policy.id
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.api_gw_endpoints[*]
    content {
      path_pattern     = ordered_cache_behavior.value.name == "study" ? "/${var.env}/api/*" : "/${var.env}/api/${ordered_cache_behavior.value.name}/*"
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = ordered_cache_behavior.value.name

      default_ttl            = 0
      min_ttl                = 0
      max_ttl                = 0
      viewer_protocol_policy = "https-only"
      forwarded_values {
        query_string = false
        cookies {
          forward = "all"
        }
      }
    }
  }

  # Distributes content to US and Europe
  price_class = "PriceClass_100"
  # Restricts who is able to access this content
  restrictions {
    geo_restriction {
      # type of restriction, blacklist, whitelist or none
      restriction_type = "none"
    }
  }
  # SSL certificate for the service.
  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  logging_config {
    bucket          = "${var.cf_logs_bucket}.s3.amazonaws.com"
    include_cookies = true
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 403
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 404
    response_page_path    = "/index.html"
  }

  web_acl_id = var.waf_arn

  tags = {
    Name        = var.name
    Environment = var.env
    System      = var.system
  }

}

