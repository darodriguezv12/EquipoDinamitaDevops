variable "name_prefix" {
  description = "Prefix used for security group names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "app_port" {
  description = "Container application port."
  type        = number
}

variable "db_port" {
  description = "Database port."
  type        = number
}
