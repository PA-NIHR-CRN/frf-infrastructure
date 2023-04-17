variable "name" {}
variable "env" {}
variable "system" {}

variable "waf_create" {
  description = "Change to false to avoid deploying any resources"
  type        = bool
  default     = true
}

variable "ip_set_name" {}
variable "whitelist_ips" {
  type = list(string)

}
variable "log_group" {}
variable "enable_logging" {}