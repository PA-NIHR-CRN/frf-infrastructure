terraform {
  backend "s3" {
    bucket  = "crnccd-s3-terraform-state"
    key     = "frf/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }

}


provider "aws" {
  region = "eu-west-2"
}

## CLOUDWATCH ALARMS

module "cloudwatch_alarms" {
  source            = "./modules/cloudwatch_alarms"
  account           = var.names["${var.env}"]["accountidentifiers"]
  env               = var.env
  system            = var.names["system"]
  app               = var.names["${var.env}"]["app"]
  sns_topic         = var.names["${var.env}"]["sns_topic"]
  cluster_instances = module.rds_aurora.db_instances
}

## RDS DB

module "rds_aurora" {
  source                  = "./modules/auroradb"
  account                 = var.names["${var.env}"]["accountidentifiers"]
  env                     = var.env
  system                  = var.names["system"]
  app                     = var.names["${var.env}"]["app"]
  vpc_id                  = var.names["${var.env}"]["vpcid"]
  subnet_ids              = var.names["${var.env}"]["publicsubnetids"]
  engine                  = var.names["${var.env}"]["engine"]
  instance_class          = var.names["${var.env}"]["instanceclass"]
  backup_retention_period = var.names["${var.env}"]["backupretentionperiod"]
  maintenance_window      = var.names["${var.env}"]["maintenancewindow"]
  grant_dev_db_access     = var.names["${var.env}"]["grant_dev_db_access"]
  vpc_ip                  = var.names["${var.env}"]["vpc_ip"]
  db_name                 = "frf"
  instance_count          = var.names["${var.env}"]["rds_instance_count"]
  az_zones                = var.names["${var.env}"]["az_zones"]
  min_capacity            = var.names["${var.env}"]["min_capacity"]
  max_capacity            = var.names["${var.env}"]["max_capacity"]
  skip_final_snapshot     = var.names["${var.env}"]["skip_final_snapshot"]
  log_types               = var.names["${var.env}"]["log_types"]
  publicly_accessible     = var.names["${var.env}"]["publicly_accessible"]
  add_scheduler_tag       = var.names["${var.env}"]["add_scheduler_tag"]
}

## ECS FARGATE

module "ecs" {
  source                      = "./modules/ecs"
  account                     = var.names["${var.env}"]["account"]
  env                         = var.env
  system                      = var.names["system"]
  vpc_id                      = var.names["${var.env}"]["vpc"]
  ecs_subnets                 = (var.names["${var.env}"]["ecs_subnet"])
  container_name              = "${var.names["${var.env}"]["account"]}-frf-${var.names["system"]}-${var.env}"
  image_url                   = var.names["${var.env}"]["kafka_ui_image"]
  bootstrap_servers           = module.msk_cluster.msk_brokers
  zookeeper_connection_string = module.msk_cluster.zookeeper_connection_string
  logs_bucket                 = var.names["${var.env}"]["access_logs_bucket"]
  api_stage                   = "v1"
  domain_name                 = var.env == "prod" ? "kafka-ui.nsip.nihr.ac.uk" : "${var.env}.kafka-ui.nsip.nihr.ac.uk"
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = "${var.names["${var.env}"]["account"]}-ecr-${var.names["system"]}-${var.env}-repository"
  env       = var.env
}

module "frf_acm" {
  source         = "./modules/acm"
  domain_name    = var.env == "prod" ? "commonid.nsip.nihr.ac.uk" : "${var.env}.commonid.nsip.nihr.ac.uk"
  env            = var.env
  system         = var.names["app"]
  api_gateway_id = var.names["${var.env}"]["commonid-api"]
  api_stage      = var.env
}

## CLOUDFRONT

module "cloudfront" {
  source           = "./modules/cloudfront"
  system           = var.names["system"]
  web_bucket_name  = "${var.names["${var.env}"]["account"]}-s3-${var.env}-${var.names["system"]}-${var.names["buckets"]["static_data"]}"
  name             = "${var.names["${var.env}"]["account"]}-cloudfront-${var.env}-${var.names["system"]}-${var.names["cloudfront"]}"
  api_gateway_url  = module.api_gateway.api_study_url
  env              = var.env
  domain_name      = var.names["${var.env}"]["domain_name"]
  website_endpoint = module.buckets.website_endpoint
  cf_logs_bucket   = "${var.names["${var.env}"]["account"]}-s3-${var.env}-${var.names["system"]}-${var.names["buckets"]["cloudfront-log"]}"
  api_gw_endpoints = module.api_gateway.api_gw_endpoints
  dns_name         = var.names["${var.env}"]["dns_name"]
  acm_arn          = var.names["${var.env}"]["acm_arn"]
  waf_arn          = var.names[var.env]["waf_associate"] == "true" ? module.waf.waf_arn : var.names[var.env]["waf_arn"]
  cf_policy_name   = "${var.names["${var.env}"]["account"]}-cloudfront-${var.env}-${var.names["system"]}-headers-policy"
}

## WAF

module "waf" {
  source         = "./modules/waf"
  name           = var.names["${var.env}"]["waf_name"]
  env            = var.env
  waf_create     = var.names[var.env]["waf_create"]
  system         = var.names["system"]
  ip_set_name    = var.names["${var.env}"]["ip_set_name"]
  whitelist_ips  = var.names["${var.env}"]["whitelist_ips"]
  enable_logging = var.names["${var.env}"]["enable_logging"]
  log_group      = var.names["${var.env}"]["log_group"]
}
