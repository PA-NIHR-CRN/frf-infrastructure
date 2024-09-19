resource "aws_wafv2_web_acl" "main" {
  name        = var.name
  description = var.description
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "${var.name}-blockedips"
    priority = 0

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = var.waf_ip_set_blockedips_arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-blockedips-metric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "${var.name}-commonruleset"
    priority = 1

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "NoUserAgent_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "UserAgent_BadBots_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_QUERYSTRING"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_Cookie_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_BODY"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_URIPATH"
        }
        rule_action_override {
          action_to_use {
            count {}
          }
          name = "EC2MetaDataSSRF_BODY"
        }
        rule_action_override {
          action_to_use {
            count {}
          }
          name = "EC2MetaDataSSRF_COOKIE"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "EC2MetaDataSSRF_URIPATH"
        }
        rule_action_override {
          action_to_use {
            count {}
          }
          name = "EC2MetaDataSSRF_QUERYARGUMENTS"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "RestrictedExtensions_URIPATH"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "RestrictedExtensions_QUERYARGUMENTS"
        }
        rule_action_override {
          action_to_use {
            count {}
          }
          name = "GenericRFI_QUERYARGUMENTS"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "GenericRFI_BODY"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "GenericRFI_URIPATH"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "CrossSiteScripting_COOKIE"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "CrossSiteScripting_QUERYARGUMENTS"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "CrossSiteScripting_BODY"
        }
        rule_action_override {
          action_to_use {
            count {}
          }

          name = "CrossSiteScripting_URIPATH"
        }

      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.name}-commonruleset"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "${var.name}-blockedips"
    priority = 0

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = var.waf_ip_set_arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-blockedips-metric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "${var.name}-knownbadnnputsruleset"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "Host_localhost_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "PROPFIND_METHOD"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-knownbadnnputsruleset-metric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "${var.name}-ipreputationlist"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "AWSManagedIPReputationList"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "AWSManagedReconnaissanceList"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-ipreputationlist-metric"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.env == "test" ? [1] : []
    content {
    name     = "${var.name}-allow-webtest-user-agent"
    priority = 4

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "user-agent"
          }
        }
        search_string = var.http_user_agent
        positional_constraint = "CONTAINS"
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.name}-allow-webtest-user-agent-metric"
      sampled_requests_enabled   = false
    }
  }
}

  rule {
    name     = "${var.name}-httpfloodprotection"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"

        scope_down_statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = var.waf_ip_set_arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.name}-httpfloodprotection-metric"
      sampled_requests_enabled   = false
    }
  }

  dynamic "rule" {
    for_each = var.env == "oat" || var.env == "prod" ? [1] : []
    content {
      name     = "${var.name}-botcontrolruleset"
      priority = 5

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesBotControlRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-botcontrol-metric"
        sampled_requests_enabled   = true
      }
    }
  }


  tags = {
    Name        = var.name
    Environment = var.env
    System      = var.system
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-metric"
    sampled_requests_enabled   = false
  }
}