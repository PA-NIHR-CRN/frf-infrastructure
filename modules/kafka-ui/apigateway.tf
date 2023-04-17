resource "aws_iam_role" "nsip_api_gateway_role" {
  name = "${var.account}-iam-${var.env}-nsip-api-gateway-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com", "events.amazonaws.com", "lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  tags = {
    Name        = "${var.account}-iam-${var.env}-nsip-api-gateway-role",
    Environment = var.env,
    System      = "nsip",
  }
}

resource "aws_api_gateway_account" "nsip_iam_apigateway_account" {
  cloudwatch_role_arn = aws_iam_role.nsip_api_gateway_role.arn
  lifecycle {
    ignore_changes = [
      cloudwatch_role_arn
    ]
  }
}

resource "aws_iam_role_policy" "nsip-apigateway-role-policy-rts" {
  name = "${var.account}-iam-${var.env}-nsip-api-gateway-role-policy"
  role = aws_iam_role.nsip_api_gateway_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "events:PutRule",
          "events:ListRules",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "sqs:SendMessage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_api_gateway_vpc_link" "main" {
  name        = "${var.account}-vpc-link-${var.env}-nsip"
  description = "allows public API Gateway to talk to private NLB"
  target_arns = [aws_lb.main.arn]
}

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.account}-api-gateway-${var.env}-nsip-kafka-ui-rest-api"
  description = "NSIP Funding Application Kafka ui API Gateway."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "main" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "v1"
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}


resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.main.dns_name}/v1/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.main.id
  timeout_milliseconds    = 29000 # 50-29000

  cache_key_parameters = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = aws_api_gateway_method_response.main.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "main" {
  depends_on  = [aws_api_gateway_integration.main]
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "v1"
}

# resource "aws_api_gateway_base_path_mapping" "main" {
#   api_id      = aws_api_gateway_rest_api.main.id
#   stage_name  = aws_api_gateway_deployment.main.stage_name
#   domain_name = aws_api_gateway_domain_name.main.domain_name
# }

# //The API Gateway endpoint
# output "api_gateway_endpoint" {
#   value = "https://${aws_api_gateway_domain_name.main.domain_name}"
# }