variable "aws_region" {
  description = "AWS region for the academic development environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name used in AWS resource names."
  type        = string
  default     = "blacklist-api"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Two availability zones used by ALB, ECS and the DB subnet group."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Use exactly two availability zones to keep this environment small and compatible with ALB requirements."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets. NAT Gateway is intentionally not used."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Use exactly two public subnets."
  }
}

variable "app_port" {
  description = "Port exposed by the Flask container."
  type        = number
  default     = 5000
}

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check."
  type        = string
  default     = "/ping"
}

variable "ecr_repository_name" {
  description = "ECR repository that stores the microservice image."
  type        = string
  default     = "proyecto-1-blacklist-api-dev"
}

variable "max_untagged_images" {
  description = "Maximum untagged images retained in ECR to reduce storage usage."
  type        = number
  default     = 1
}

variable "max_tagged_image_count" {
  description = "Maximum total images retained in ECR to reduce storage usage."
  type        = number
  default     = 5
}

variable "container_image_tag" {
  description = "Initial image tag used by the ECS task definition."
  type        = string
  default     = "latest"
}

variable "ecs_desired_count" {
  description = "Number of Fargate tasks. Default is one for academic low-cost use."
  type        = number
  default     = 1

  validation {
    condition     = var.ecs_desired_count == 1
    error_message = "Keep desired_count at 1 for the initial low-cost academic environment."
  }
}

variable "task_cpu" {
  description = "Fargate task CPU units. 256 equals 0.25 vCPU."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 3
}

variable "api_token" {
  description = "Bearer token expected by the API."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
  default     = "blacklistdb"
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL master password. Use a non-production value for this academic dev environment."
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "PostgreSQL port."
  type        = number
  default     = 5432
}

variable "db_instance_class" {
  description = "Low-cost RDS instance class. db.t3.micro/db.t4g.micro may be Free Tier/Free Plan eligible depending on account conditions."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Optional maximum RDS autoscaled storage in GiB. Keep null to avoid autoscaling in the low-cost academic environment."
  type        = number
  default     = null
  nullable    = true
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "15"
}

variable "db_init_retries" {
  description = "Application DB initialization retry count."
  type        = number
  default     = 5
}

variable "db_init_delay" {
  description = "Application DB initialization retry delay in seconds."
  type        = number
  default     = 2
}

variable "codedeploy_service_role_name" {
  description = "IAM role name reserved for future ECS Blue/Green deployments with CodeDeploy."
  type        = string
  default     = "blacklist-api-dev-codedeploy-ecs"
}
