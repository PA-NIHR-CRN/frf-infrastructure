resource "aws_acm_certificate" "kafka_ui_cert" {
  domain_name       = var.domain_name
  validation_method = "EMAIL"

  validation_option {
    domain_name       = var.domain_name
    validation_domain = "nihr.ac.uk"
  }
  tags = {
    Environment = var.env
    Name        = var.domain_name
    System      = "nsip"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      validation_option
    ]
  }
}

resource "aws_api_gateway_domain_name" "kafka_ui_domain" {
  domain_name              = aws_acm_certificate.kafka_ui_cert.domain_name
  regional_certificate_arn = aws_acm_certificate.kafka_ui_cert.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  security_policy = "TLS_1_2"
  tags = {
    Environment = var.env
    Name        = var.domain_name
    System      = "nsip"
  }
  depends_on = [
    aws_acm_certificate.kafka_ui_cert
  ]
}

resource "aws_api_gateway_base_path_mapping" "kafka_ui_path_mapping" {
  api_id      = aws_api_gateway_rest_api.main.id
  domain_name = aws_api_gateway_domain_name.kafka_ui_domain.domain_name
  stage_name  = var.api_stage
  base_path   = var.api_stage
}
