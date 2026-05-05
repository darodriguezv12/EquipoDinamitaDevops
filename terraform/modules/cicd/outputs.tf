output "pipeline_name" {
  description = "CodePipeline name."
  value       = aws_codepipeline.this.name
}

output "codebuild_project_name" {
  description = "CodeBuild project name."
  value       = aws_codebuild_project.this.name
}

output "codedeploy_app_name" {
  description = "CodeDeploy application name."
  value       = aws_codedeploy_app.this.name
}

output "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name."
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "codedeploy_service_role_arn" {
  description = "CodeDeploy service role ARN."
  value       = aws_iam_role.codedeploy.arn
}

output "artifact_bucket_name" {
  description = "Pipeline artifact bucket name."
  value       = aws_s3_bucket.artifacts.bucket
}
