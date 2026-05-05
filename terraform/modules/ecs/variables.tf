variable "name_prefix" {
  description = "Prefix used for ECS resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for Fargate tasks."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group attached to Fargate tasks."
  type        = string
}

variable "container_image" {
  description = "Full container image URI."
  type        = string
}

variable "container_port" {
  description = "Container port."
  type        = number
}

variable "target_group_arn" {
  description = "Initial ALB target group ARN."
  type        = string
}

variable "desired_count" {
  description = "Desired Fargate task count."
  type        = number
}

variable "task_cpu" {
  description = "Task CPU units."
  type        = number
}

variable "task_memory" {
  description = "Task memory in MiB."
  type        = number
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

variable "api_token" {
  description = "API bearer token."
  type        = string
  sensitive   = true
}

variable "database_url" {
  description = "SQLAlchemy database URL."
  type        = string
  sensitive   = true
}

variable "db_init_retries" {
  description = "DB initialization retry count."
  type        = number
}

variable "db_init_delay" {
  description = "DB initialization retry delay."
  type        = number
}

variable "codedeploy_service_role_name" {
  description = "IAM role name reserved for future CodeDeploy ECS deployments."
  type        = string
}
