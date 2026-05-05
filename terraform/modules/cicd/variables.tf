variable "name_prefix" {
  description = "Prefix used for CI/CD resource names."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "github_connection_arn" {
  description = "CodeConnections ARN used by CodePipeline."
  type        = string
}

variable "github_full_repository_id" {
  description = "GitHub repository in owner/name format."
  type        = string
}

variable "github_branch_name" {
  description = "GitHub branch used as Source."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN."
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL."
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name."
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name."
  type        = string
}

variable "alb_listener_arn" {
  description = "ALB production listener ARN used by CodeDeploy."
  type        = string
}

variable "blue_target_group_name" {
  description = "Blue target group name used by CodeDeploy."
  type        = string
}

variable "green_target_group_name" {
  description = "Green target group name used by CodeDeploy."
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN."
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECS task role ARN."
  type        = string
}

variable "container_name" {
  description = "ECS container name used in appspec.json and taskdef.json."
  type        = string
}

variable "artifact_retention_days" {
  description = "Days to retain CodePipeline artifacts."
  type        = number
}
