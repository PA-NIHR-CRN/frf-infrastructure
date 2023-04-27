variable "names" {
  default = {
    "retention_in_days" = "30"
    "proj"              = "crncc"
    "system"            = "frf"
    "app"               = "frf"

    "dev" = {
      "accountidentifiers"    = "crnccd"
      "environment"           = "dev"
      "app"                   = "frf"
      "backupretentionperiod" = 1
      "engine"                = "mysql"
      "engine_version"        = "8.0.mysql_aurora.3.02.2"
      "instanceclass"         = "db.serverless"
      "skip_final_snapshot"   = true
      "publicsubnetids"       = ["subnet-067afb7d7e5af4f36", "subnet-093eeb64493db3d5f", "subnet-028fefa4bcb581e7e"]
      "vpcid"                 = "vpc-09e81adb48e5eda99"
      "maintenancewindow"     = "Sat:04:00-Sat:05:00"
      "storageencrypted"      = true
      "grant_dev_db_access"   = true
      "container_image_url"   = ""
      "rds_instance_count"    = "1"
      "az_zones"              = ["eu-west-2a"]
      "min_capacity"          = 0.5
      "max_capacity"          = 4
      "log_types"             = ["error", "general", "slowquery"]
      "publicly_accessible"   = true
      "add_scheduler_tag"     = true
      "ecs_instance_count"    = 1
    }
  }
}