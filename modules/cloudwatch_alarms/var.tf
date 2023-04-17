variable "account" {
  default = "nihrd"
}

variable "system" {
  default = "nsip"

}

variable "env" {
  default = "dev"

}

variable "sns_topic" {
}

variable "app" {

}

variable "cluster_instances" {

}

variable "api_gateway_list" {
  type    = list(any)
  default = []
}

variable "api_gateway_stage" {
  type    = list(any)
  default = []
}

# -----------------------------------------------------------------------------
# Variables: Cloudwatch Alarms Latency
# -----------------------------------------------------------------------------

variable "resources" {
  description = "Methods that have Cloudwatch alarms enabled"
  type        = map(any)
  default     = {}
}

variable "latency_threshold_p95" {
  description = "The value against which the specified statistic is compared"
  default     = 1000
}

variable "latency_threshold_p99" {
  description = "The value against which the specified statistic is compared"
  default     = 1000
}

variable "latency_evaluationPeriods" {
  description = "The number of periods over which data is compared to the specified threshold"
  default     = 5
}

variable "fourRate_threshold" {
  description = "Percentage of errors that will trigger an alert"
  default     = 0.02
  type        = number
}

variable "fourRate_evaluationPeriods" {
  description = "How many periods are evaluated before the alarm is triggered"
  default     = 5
  type        = number
}

variable "fiveRate_threshold" {
  description = "Percentage of errors that will trigger an alert"
  default     = 0.02
  type        = number
}

variable "fiveRate_evaluationPeriods" {
  description = "How many periods are evaluated before the alarm is triggered"
  default     = 5
  type        = number
}