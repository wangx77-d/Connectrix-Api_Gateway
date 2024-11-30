variable "app_name" {
  type        = string
  description = "Application Name"
  default = "Connectrix-Api_Gateway"
}

variable "websocket_table_name" {
  type        = string
  description = "Name of the web socket connection table in dynamo db"
  default     = "websocket-connections"
}

variable "sqs_queue_name" {
  type        = string
  description = "Queue name"
  default     = "connectrix-studio-notification"
}

variable "api_gateway_stage_name" {
    type        = string
    default     = "primary"
}

variable "image_tag" {}

variable "aws_region" {}