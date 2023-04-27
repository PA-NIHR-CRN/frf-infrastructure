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

#env
variable "bootstrap_servers" {
}

variable "instance_count" {
}
variable "lb_arn" {
}

#LB

variable "security_group_ids" {
  description = "list of security group ids for LB"
  type        = list(any)

}