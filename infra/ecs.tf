resource "aws_ecs_express_gateway_service" "app" {
  service_name            = "wishifai-${var.candidate_number}"
  execution_role_arn      = "arn:aws:iam::${local.account_id}:role/ecsTaskExecutionRole"
  infrastructure_role_arn = "arn:aws:iam::${local.account_id}:role/service-role/ecsInfrastructureRoleForExpressServices"
  task_role_arn           = aws_iam_role.task.arn
  health_check_path       = "/actuator/health"
  wait_for_steady_state   = true

  primary_container {
    image          = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.candidate_number}-wishifai:${var.image_tag}"
    container_port = 8080

    environment {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.images.bucket
    }

    environment {
      name  = "AWS_REGION"
      value = var.region
    }
  }

  depends_on = [aws_iam_role_policy.task]
}