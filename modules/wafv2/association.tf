resource "aws_wafv2_web_acl_association" "main" {

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn

  depends_on = [aws_wafv2_web_acl.main]
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = var.log_group
  resource_arn            = aws_wafv2_web_acl.main.arn
}