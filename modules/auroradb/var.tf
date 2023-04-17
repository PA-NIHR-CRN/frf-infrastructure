variable "account" {
  default = "nihrd"
}

variable "system" {
  default = "nsip"

}

variable "env" {
  default = "dev"

}

variable "app" {

}

variable "subnet_ids" {
  type = list(any)

}

variable "vpc_id" {

}

variable "engine" {

}

variable "instance_class" {

}



variable "backup_retention_period" {

}

variable "maintenance_window" {

}

variable "grant_dev_db_access" {
  default = true

}

variable "vpc_ip" {
}

variable "az_zones" {
  type = list(any)

}

variable "db_name" {

}

variable "instance_count" {

}

variable "max_capacity" {

}

variable "min_capacity" {

}

variable "skip_final_snapshot" {

}

variable "publicly_accessible" {

}

variable "log_types" {
  type = list(string)

}

variable "add_scheduler_tag" {

}

# variable "capacity" {
#   default = null

#   type = object({
#     min_capacity = number
#     max_capacity = number
#   })
# }