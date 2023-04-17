variable "env" {
  description = "environment name"
  type        = string

}

variable "system" {
  type = string
}

variable "vpc_id" {
  description = "vpc id"
  type        = string

}

variable "ecs_subnets" {
  description = "list of subnets for ecs"
  type        = list(any)

}

variable "account" {
  description = "account name"
  type        = string
  default     = "nihrd"

}


variable "container_name" {
  description = "container"
  type        = string

}


variable "image_url" {
  description = "container image url"
  type        = string


}


#lB
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "TCP"
}

variable "bootstrap_servers" {
}

variable "zookeeper_connection_string" {
}

variable "logs_bucket" {

}

variable "api_stage" {
}

variable "domain_name" {}
