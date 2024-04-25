variable "name" {

}

variable "waf_ip_set_arn" {

}

variable "waf_ip_set_blockedips_arn" {

}

variable "env" {

}

variable "system" {

}

variable "alb_arn" {

}

variable "description" {
  type        = string
  description = "A friendly description of the WebACL"
  default     = null
}

variable "log_group" {

}