terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      CostProfile = "academic-low-cost"
    }
  }
}

moved {
  from = module.ecs.aws_iam_role.codedeploy
  to   = module.cicd.aws_iam_role.codedeploy
}

moved {
  from = module.ecs.aws_iam_role_policy_attachment.codedeploy_ecs
  to   = module.cicd.aws_iam_role_policy_attachment.codedeploy
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "network" {
  source = "../../modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "security" {
  source = "../../modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
  app_port    = var.app_port
  db_port     = var.db_port
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name        = var.ecr_repository_name
  max_untagged_images    = var.max_untagged_images
  max_tagged_image_count = var.max_tagged_image_count
}

module "alb" {
  source = "../../modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  alb_security_group = module.security.alb_security_group_id
  app_port           = var.app_port
  health_check_path  = var.health_check_path
}

module "rds" {
  source = "../../modules/rds"

  name_prefix              = local.name_prefix
  subnet_ids               = module.network.public_subnet_ids
  db_security_group_id     = module.security.rds_security_group_id
  db_name                  = var.db_name
  db_username              = var.db_username
  db_password              = var.db_password
  db_instance_class        = var.db_instance_class
  db_allocated_storage     = var.db_allocated_storage
  db_max_allocated_storage = var.db_max_allocated_storage
  db_engine_version        = var.db_engine_version
  db_port                  = var.db_port
}

module "ecs" {
  source = "../../modules/ecs"

  name_prefix           = local.name_prefix
  aws_region            = var.aws_region
  public_subnet_ids     = module.network.public_subnet_ids
  ecs_security_group_id = module.security.ecs_security_group_id
  container_image       = "${module.ecr.repository_url}:${var.container_image_tag}"
  container_port        = var.app_port
  target_group_arn      = module.alb.blue_target_group_arn
  desired_count         = var.ecs_desired_count
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  log_retention_days    = var.log_retention_days
  api_token             = var.api_token
  db_init_retries       = var.db_init_retries
  db_init_delay         = var.db_init_delay
  database_url          = "postgresql://${var.db_username}:${var.db_password}@${module.rds.db_endpoint}/${var.db_name}"
}

module "cicd" {
  source = "../../modules/cicd"

  name_prefix                 = local.name_prefix
  aws_region                  = var.aws_region
  github_connection_arn       = var.github_connection_arn
  github_full_repository_id   = var.github_full_repository_id
  github_branch_name          = var.github_branch_name
  ecr_repository_arn          = module.ecr.repository_arn
  ecr_repository_url          = module.ecr.repository_url
  ecs_cluster_name            = module.ecs.cluster_name
  ecs_service_name            = module.ecs.service_name
  alb_listener_arn            = module.alb.listener_arn
  blue_target_group_name      = module.alb.blue_target_group_name
  green_target_group_name     = module.alb.green_target_group_name
  ecs_task_execution_role_arn = module.ecs.task_execution_role_arn
  ecs_task_role_arn           = module.ecs.task_role_arn
  container_name              = "app"
  artifact_retention_days     = var.pipeline_artifact_retention_days
}
