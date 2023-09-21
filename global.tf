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
      "backupretentionperiod" = 7
      "engine"                = "mysql"
      "engine_version"        = "8.0.mysql_aurora.3.02.2"
      "instanceclass"         = "db.serverless"
      "skip_final_snapshot"   = true
      "rds_subnet_ids"        = ["subnet-04ad191ac2b66d763", "subnet-093eeb64493db3d5f", "subnet-028fefa4bcb581e7e"]
      "vpcid"                 = "vpc-09e81adb48e5eda99"
      "maintenancewindow"     = "Sat:04:00-Sat:05:00"
      "storageencrypted"      = true
      "grant_dev_db_access"   = true
      "ecs_subnet"            = ["subnet-067afb7d7e5af4f36", "subnet-0ab17287bb419808a"]
      "lb_subnet"             = ["subnet-04ad191ac2b66d763", "subnet-093eeb64493db3d5f"]
      "rds_instance_count"    = "1"
      "az_zones"              = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
      "min_capacity"          = 0.5
      "max_capacity"          = 4
      "log_types"             = ["error", "general", "slowquery"]
      "publicly_accessible"   = true
      "add_scheduler_tag"     = true
      "ecs_instance_count"    = 1
      "waf_create"            = "true"
      "whitelist_ips"         = ["0.0.0.0/0"]
    }

    "test" = {
      "accountidentifiers"    = "crnccd"
      "environment"           = "test"
      "app"                   = "frf"
      "backupretentionperiod" = 7
      "engine"                = "mysql"
      "engine_version"        = "8.0.mysql_aurora.3.02.2"
      "instanceclass"         = "db.serverless"
      "skip_final_snapshot"   = true
      "rds_subnet_ids"        = ["subnet-012b28f51a536264f", "subnet-0b31379ceb59b3aa2", "subnet-0ba1a98976515a663"]
      "vpcid"                 = "vpc-068eed99b0e17ce20"
      "maintenancewindow"     = "Sat:04:00-Sat:05:00"
      "storageencrypted"      = true
      "grant_dev_db_access"   = true
      "ecs_subnet"            = ["subnet-013380fc814fcd7a8", "subnet-026e43c345c497f81"]
      "lb_subnet"             = ["subnet-012b28f51a536264f", "subnet-0b31379ceb59b3aa2"]
      "rds_instance_count"    = "1"
      "az_zones"              = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
      "min_capacity"          = 0.5
      "max_capacity"          = 4
      "log_types"             = ["error", "general", "slowquery"]
      "publicly_accessible"   = true
      "add_scheduler_tag"     = true
      "ecs_instance_count"    = 1
      "waf_create"            = "true"
      "whitelist_ips"         = ["0.0.0.0/0"]
    }

    "uat" = {
      "accountidentifiers"    = "crnccs"
      "environment"           = "uat"
      "app"                   = "frf"
      "backupretentionperiod" = 7
      "engine"                = "mysql"
      "engine_version"        = "8.0.mysql_aurora.3.02.2"
      "instanceclass"         = "db.serverless"
      "skip_final_snapshot"   = true
      "rds_subnet_ids"        = ["subnet-014f7c22b8ca588d2", "subnet-0393f098f6159948e", "subnet-09e5c6a3d81301bbd"]
      "vpcid"                 = "vpc-0da5dc0e5af1c5e2c"
      "maintenancewindow"     = "Sat:04:00-Sat:05:00"
      "storageencrypted"      = true
      "grant_dev_db_access"   = true
      "ecs_subnet"            = ["subnet-014f7c22b8ca588d2", "subnet-0393f098f6159948e"]
      "lb_subnet"             = ["subnet-0eda6aac2aa3f6a8a", "subnet-0e0d905781bfc0687"]
      "container_image_url"   = ""
      "rds_instance_count"    = "1"
      "az_zones"              = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
      "min_capacity"          = 0.5
      "max_capacity"          = 4
      "log_types"             = ["error", "general", "slowquery"]
      "publicly_accessible"   = true
      "add_scheduler_tag"     = true
      "ecs_instance_count"    = 1
      "waf_create"            = "true"
      "whitelist_ips"         = ["0.0.0.0/0"]
    }

    "oat" = {
      "accountidentifiers"    = "crnccp"
      "environment"           = "oat"
      "app"                   = "frf"
      "backupretentionperiod" = 1
      "engine"                = "mysql"
      "engine_version"        = "8.0.mysql_aurora.3.02.2"
      "instanceclass"         = "db.serverless"
      "skip_final_snapshot"   = true
      "rds_subnet_ids"        = ["subnet-0c5ed34136a1896d5", "subnet-0c599b4c6ea142959", "subnet-052279d19b778a506"]
      "vpcid"                 = "vpc-00bff92313277a8b5"
      "maintenancewindow"     = "Sat:04:00-Sat:05:00"
      "storageencrypted"      = true
      "grant_dev_db_access"   = true
      "ecs_subnet"            = ["subnet-0c5ed34136a1896d5", "subnet-0c599b4c6ea142959", "subnet-052279d19b778a506"]
      "lb_subnet"             = ["subnet-046f1aadc23c50b9c", "subnet-07cb31be0a01cd0ca", "subnet-0f176c1fd30d60574"]
      "rds_instance_count"    = "3"
      "az_zones"              = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
      "min_capacity"          = 0.5
      "max_capacity"          = 4
      "log_types"             = ["error", "general", "slowquery"]
      "publicly_accessible"   = true
      "add_scheduler_tag"     = true
      "ecs_instance_count"    = 3
      "waf_create"            = "true"
      "whitelist_ips"         = ["0.0.0.0/0"]
    }

    "prod" = {
      "accountidentifiers"    = "crnccp"
      "environment"           = "prod"
      "app"                   = "frf"
      "backupretentionperiod" = "7"
      "engine"                = "mysql"
      "engine_version"        = "8.0.mysql_aurora.3.02.2"
      "instanceclass"         = "db.serverless"
      "skip_final_snapshot"   = true
      "rds_subnet_ids"        = ["subnet-05f4307eb2a2d1f10", "subnet-080e771c9db3aa1fc", "subnet-025c35dccad5330e4"]
      "vpcid"                 = "vpc-04ff203f97bb57c4c"
      "maintenancewindow"     = "Sat:04:00-Sat:05:00"
      "storageencrypted"      = true
      "grant_dev_db_access"   = true
      "ecs_subnet"            = ["subnet-05f4307eb2a2d1f10", "subnet-080e771c9db3aa1fc", "subnet-025c35dccad5330e4"]
      "lb_subnet"             = ["subnet-0f22b341632d789a6", "subnet-0122964cc845a1b61", "subnet-035cab03e4bd37e4f"]
      "rds_instance_count"    = "3"
      "az_zones"              = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
      "min_capacity"          = 0.5
      "max_capacity"          = 4
      "log_types"             = ["error", "general", "slowquery"]
      "publicly_accessible"   = true
      "add_scheduler_tag"     = true
      "ecs_instance_count"    = 3
      "waf_create"            = "true"
      "whitelist_ips"         = ["0.0.0.0/0"]
    }
  }
}