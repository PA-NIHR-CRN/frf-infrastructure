terraform {
  backend "s3" {
    region  = "eu-west-2"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

## CLOUDWATCH ALARMS

data "aws_sns_topic" "system_alerts" {
  name = "${var.names["${var.env}"]["accountidentifiers"]}-sns-system-alerts"
}

data "aws_sns_topic" "system_alerts_oat" {
  count = var.env == "oat" ? 1 : 0
  name  = "${var.names["${var.env}"]["accountidentifiers"]}-sns-system-alerts-oat"
}

module "cloudwatch_alarms" {
  source            = "./modules/cloudwatch_alarms"
  account           = var.names["${var.env}"]["accountidentifiers"]
  env               = var.env
  system            = var.names["system"]
  app               = var.names["${var.env}"]["app"]
  sns_topic         = var.env == "oat" ? data.aws_sns_topic.system_alerts_oat[0].arn : data.aws_sns_topic.system_alerts.arn
  cluster_instances = module.rds_aurora.db_instances
  load_balancer_id  = module.ecs.lb_suffix
  target_group_id   = module.ecs.tg_suffix
}

data "aws_secretsmanager_secret" "terraform_secret" {
  name = "${var.names["${var.env}"]["accountidentifiers"]}-secret-${var.env}-${var.names["system"]}-terraform"
}

data "aws_secretsmanager_secret_version" "terraform_secret_version" {
  secret_id = data.aws_secretsmanager_secret.terraform_secret.id
}

## RDS DB
module "rds_aurora" {
  source                  = "./modules/auroradb"
  account                 = var.names["${var.env}"]["accountidentifiers"]
  env                     = var.env
  system                  = var.names["system"]
  app                     = var.names["${var.env}"]["app"]
  vpc_id                  = var.names["${var.env}"]["vpcid"]
  engine                  = var.names["${var.env}"]["engine"]
  engine_version          = var.names["${var.env}"]["engine_version"]
  instance_class          = var.names["${var.env}"]["instanceclass"]
  backup_retention_period = var.names["${var.env}"]["backupretentionperiod"]
  maintenance_window      = var.names["${var.env}"]["maintenancewindow"]
  grant_dev_db_access     = var.names["${var.env}"]["grant_dev_db_access"]
  subnet_group            = "${var.names["${var.env}"]["accountidentifiers"]}-rds-sng-${var.env}-public"
  db_name                 = "frf"
  username                = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["db-username"]
  instance_count          = var.names["${var.env}"]["rds_instance_count"]
  az_zones                = var.names["${var.env}"]["az_zones"]
  min_capacity            = var.names["${var.env}"]["min_capacity"]
  max_capacity            = var.names["${var.env}"]["max_capacity"]
  skip_final_snapshot     = var.names["${var.env}"]["skip_final_snapshot"]
  log_types               = var.names["${var.env}"]["log_types"]
  publicly_accessible     = var.names["${var.env}"]["publicly_accessible"]
  add_scheduler_tag       = var.names["${var.env}"]["add_scheduler_tag"]
  ecs_sg                  = module.ecs.ecs_sg
  ingress_rules           = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["ingress_rules"]
}

## ECS FARGATE

module "ecs" {
  source           = "./modules/container-service"
  account          = var.names["${var.env}"]["accountidentifiers"]
  env              = var.env
  system           = var.names["system"]
  vpc_id           = var.names["${var.env}"]["vpcid"]
  ecs_subnets      = (var.names["${var.env}"]["ecs_subnet"])
  lb_subnets       = (var.names["${var.env}"]["lb_subnet"])
  container_name   = "${var.names["${var.env}"]["accountidentifiers"]}-ecs-${var.env}-${var.names["system"]}-container"
  instance_count   = var.names["${var.env}"]["ecs_instance_count"]
  image_url        = "${module.ecr.repository_url}:${var.names["system"]}-web"
  logs_bucket      = "gscs-aws-logs-s3-${local.account_id}-eu-west-2"
  whitelist_ips    = var.names["${var.env}"]["whitelist_ips"]
  domain_name      = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["domain-name"]
  validation_email = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["validation-email"]
  ecs_cpu          = var.names["${var.env}"]["ecs_cpu"]
  ecs_memory       = var.names["${var.env}"]["ecs_memory"]
  ingress_rules    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["ingress_rules"]
  new_relic_ips    = var.env == "prod" ? jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["new-relic-ips"] : []
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = "${var.names["${var.env}"]["accountidentifiers"]}-ecr-${var.env}-${var.names["system"]}-repository"
  env       = var.env
  system    = var.names["system"]
}

# ## WAF

data "aws_cloudwatch_log_group" "waf_log_group" {
  name = "aws-waf-logs-lg-gscs-${local.account_id}-eu-west-2"
}

data "aws_wafv2_ip_set" "ip_set" {
  name  = "gscs-waf-rate-based-excluded-ips"
  scope = "REGIONAL"
}

data "aws_wafv2_ip_set" "ip_set_blockedips" {
  name  = "gscs-waf-blocked-ips"
  scope = "REGIONAL"
}

module "waf" {
  source                    = "./modules/waf"
  name                      = "${var.names["${var.env}"]["accountidentifiers"]}-waf-${var.env}-${var.names["system"]}-acl-eu-west-2"
  env                       = var.env
  waf_create                = var.names[var.env]["waf_create"]
  waf_scope                 = "REGIONAL"
  alb_arn                   = module.ecs.lb_arn
  system                    = var.names["system"]
  enable_logging            = true
  log_group                 = [data.aws_cloudwatch_log_group.waf_log_group.arn]
  waf_ip_set_arn            = data.aws_wafv2_ip_set.ip_set.arn
  waf_ip_set_blockedips_arn = data.aws_wafv2_ip_set.ip_set_blockedips.arn
  header_name               = "findrecruitandfollowup"
  http_user_agent           = "findrecruitandfollowup-auto-agent"
}