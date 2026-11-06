output "service_url" {
  description = "Public endpoint of the service"
  value       = aws_ecs_express_gateway_service.app.ingress_paths[0].endpoint
}

output "s3_bucket" {
  description = "Bucket that stores uploaded images"
  value       = aws_s3_bucket.images.bucket
}

output "task_role_arn" {
  description = "Role the application runs as"
  value       = aws_iam_role.task.arn
}