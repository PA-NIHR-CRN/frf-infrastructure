module "waf" {
  source = "./code"
  # enabled         = data.external.check_waf_exists.result.result
  enabled     = var.waf_create
  name_prefix = var.name
  env         = var.env

  allow_default_action = true

  scope = var.waf_scope

  create_alb_association = true
  alb_arn                = var.alb_arn

  http_user_agent = var.http_user_agent
  
  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-metric"
    sampled_requests_enabled   = false
  }

  create_logging_configuration = var.enable_logging
  log_destination_configs      = var.log_group
  rules = [
    local.blocked_ips_rule,
    local.commonruleset,
    local.knownbadnnputsruleset,
    local.ipreputationlist,
    local.httpfloodprotection,
    local.hostheaderblock,
  ]
  bot_rules = ["CategoryAdvertising", "CategoryArchiver", "CategoryContentFetcher", "CategoryEmailClient", "CategoryHttpLibrary", "CategoryLinkChecker", "CategoryMiscellaneous", "CategoryMonitoring", "CategoryScrapingFramework", "CategorySearchEngine", "CategorySecurity", "CategorySeo", "CategorySocialMedia", "CategoryAI", "SignalAutomatedBrowser", "SignalKnownBotDataCenter", "SignalNonBrowserUserAgent"]

  tags = {
    Name        = var.name
    Environment = var.env
    System      = var.system
  }
}

locals {
  blocked_ips_rule = {
    name     = "${var.name}-blockedips",
    priority = 0
    action   = "block"

    ip_set_reference_statement = {
      arn = var.waf_ip_set_blockedips_arn
    }

    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-blockedips-metric"
      sampled_requests_enabled   = true
    }
  }
  commonruleset = {
    // WAF AWS Managed Rule 
    name            = "${var.name}-commonruleset"
    priority        = 1
    override_action = "none"

    managed_rule_group_statement = {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
      rule_action_overrides = [
        {
          action_to_use = {
            count = {}
          }

          name = "NoUserAgent_HEADER"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "UserAgent_BadBots_HEADER"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "SizeRestrictions_QUERYSTRING"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "SizeRestrictions_Cookie_HEADER"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "SizeRestrictions_BODY"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "SizeRestrictions_URIPATH"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "EC2MetaDataSSRF_BODY"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "EC2MetaDataSSRF_COOKIE"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "EC2MetaDataSSRF_URIPATH"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "EC2MetaDataSSRF_QUERYARGUMENTS"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "RestrictedExtensions_URIPATH"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "RestrictedExtensions_QUERYARGUMENTS"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "GenericRFI_QUERYARGUMENTS"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "GenericRFI_BODY"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "GenericRFI_URIPATH"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "CrossSiteScripting_COOKIE"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "CrossSiteScripting_QUERYARGUMENTS"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "CrossSiteScripting_BODY"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "CrossSiteScripting_URIPATH"
        },
      ]
    }

    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-commonruleset-metric"
      sampled_requests_enabled   = false
    }
  }
  knownbadnnputsruleset = {
    name            = "${var.name}-knownbadnnputsruleset",
    priority        = 2
    override_action = "none"

    managed_rule_group_statement = {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name = "AWS"
      rule_action_overrides = [
        {
          action_to_use = {
            count = {}
          }

          name = "Host_localhost_HEADER"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "PROPFIND_METHOD"
        }
      ]
    }

    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-knownbadnnputsruleset-metric"
      sampled_requests_enabled   = true
    }
  }
  ipreputationlist = {
    name            = "${var.name}-ipreputationlist",
    priority        = 3
    override_action = "none"

    managed_rule_group_statement = {
      name        = "AWSManagedRulesAmazonIpReputationList"
      vendor_name = "AWS"
      rule_action_overrides = [
        {
          action_to_use = {
            count = {}
          }

          name = "AWSManagedIPReputationList"
        },
        {
          action_to_use = {
            count = {}
          }

          name = "AWSManagedReconnaissanceList"
        }
      ]
    }

    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-ipreputationlist-metric"
      sampled_requests_enabled   = true
    }
  }

  // WAF AWS Custom Rule     
  httpfloodprotection = {
    name     = "${var.name}-httpfloodprotection",
    priority = 4
    action   = "block"

    rate_based_statement = {
      limit              = 2000
      aggregate_key_type = "IP"

      scope_down_statement = {
        not_statement = {
          statement = {
            or_statement = {
              statement = {
                ip_set_reference_statement = {
                  arn = var.waf_ip_set_arn
                }
              }
              statement = {
              byte_match_statement = {
                field_to_match = {
                  single_header = {
                    name = "user-agent"
                  }
                }
                search_string = var.http_user_agent
                positional_constraint = "CONTAINS"
                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
          }
        }
      }
    }
  }

    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-httpfloodprotection-metric"
      sampled_requests_enabled   = true
    }
  }

  hostheaderblock = {
    name     = "${var.name}-hostheaderblock",
    priority = var.env == "oat" || var.env == "prod" ? 6 : 5
    action   = "block"

    not_statement = {
      byte_match_statement = {
        field_to_match = {
          single_header = {
            name = "host"
          }
        }
        positional_constraint = "CONTAINS"
        search_string         = var.header_name
        priority              = 0
        type                  = "NONE"

      }
    }

    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-hostheaderblock-metric"
      sampled_requests_enabled   = true
    }
  }
  
  hostheadercount = {
    name     = "${var.name}-hostheadercount",
    priority = var.env == "oat" || var.env == "prod" ? 6 : 5
    action   = "count"

    not_statement = {
      byte_match_statement = {
        field_to_match = {
          single_header = {
            name = "host"
          }
        }
        positional_constraint = "CONTAINS"
        search_string         = var.header_name
        priority              = 0
        type                  = "NONE"

      }
    }

    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-hostheadercount-metric"
      sampled_requests_enabled   = true
    }
  }
}