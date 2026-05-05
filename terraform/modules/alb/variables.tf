variable "name_prefix" {
  description = "Prefix used for ALB resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_security_group" {
  description = "ALB security group ID."
  type        = string
}

variable "app_port" {
  description = "Application target port."
  type        = number
}

variable "health_check_path" {
  description = "Health check path."
  type        = string
}
