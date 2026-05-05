output "vpc_id" {
  description = "Dedicated VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by ALB, ECS and the DB subnet group."
  value       = module.network.public_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker image pushes."
  value       = module.ecr.repository_url
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "blue_target_group_arn" {
  description = "Initial production target group ARN."
  value       = module.alb.blue_target_group_arn
}

output "green_target_group_arn" {
  description = "Secondary target group ARN reserved for future CodeDeploy Blue/Green deployments."
  value       = module.alb.green_target_group_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "Private RDS endpoint. It is not publicly accessible."
  value       = module.rds.db_endpoint
}

output "codedeploy_service_role_arn" {
  description = "IAM role ARN reserved for future AWS CodeDeploy ECS Blue/Green setup."
  value       = module.ecs.codedeploy_service_role_arn
}
