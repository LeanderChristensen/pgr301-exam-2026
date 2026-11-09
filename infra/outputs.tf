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

output "dashboard_url" {
  description = "Link to the CloudWatch dashboard"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}