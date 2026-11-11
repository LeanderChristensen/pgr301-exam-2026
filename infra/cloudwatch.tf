locals {
  namespace = "wishifai-${var.candidate_number}"
  ecs_dims  = ["ClusterName", "default", "ServiceName", aws_ecs_express_gateway_service.app.service_name]
  analyze_dims = [
    "exception", "none",
    "method", "POST",
    "error", "none",
    "uri", "/api/analyze",
    "outcome", "SUCCESS",
    "status", "200",
  ]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "wishifai-${var.candidate_number}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "Bilder analysert og gaveforslag"
          region = var.region
          stat   = "Sum"
          period = 300
          metrics = [
            [local.namespace, "gift.suggestions.count", { label = "Bilder analysert" }],
            [local.namespace, "gift.suggestions.sum", { label = "Gaveforslag totalt" }],
            [local.namespace, "bedrock.parse.failures.count", { label = "Svar som ikke kunne tolkes" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "Snitt gaveforslag per bilde"
          region = var.region
          stat   = "Average"
          period = 300
          metrics = [
            [local.namespace, "gift.suggestions.avg", { label = "Forslag per bilde" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "Responstid per steg (ms)"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            [local.namespace, "bedrock.duration.avg", { label = "Bedrock" }],
            [local.namespace, "rekognition.duration.avg", { label = "Rekognition" }],
            [local.namespace, "s3.upload.duration.avg", { label = "S3-opplasting" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "ECS: CPU og minne (%)"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            concat(["AWS/ECS", "CPUUtilization"], local.ecs_dims, [{ label = "CPU" }]),
            concat(["AWS/ECS", "MemoryUtilization"], local.ecs_dims, [{ label = "Minne" }]),
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "ECS: kjørende tasks"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            concat(["AWS/ECS", "LiveTaskCount"], local.ecs_dims, [{ label = "Tasks" }]),
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 6
        width  = 8
        height = 6
        properties = {
          title  = "Actuator: /api/analyze responstid og JVM heap"
          region = var.region
          period = 60
          metrics = [
            concat([local.namespace, "http.server.requests.avg"], local.analyze_dims, [{ label = "Responstid (ms)", stat = "Average" }]),
            [{ expression = "SUM(SEARCH('{${local.namespace},area,id} MetricName=\"jvm.memory.used.value\" area=\"heap\"', 'Average', 60))", label = "Heap brukt (bytes)", id = "heap", yAxis = "right" }],
          ]
        }
      },
    ]
  })
}

resource "aws_sns_topic" "alerts" {
  name = "wishifai-${var.candidate_number}-alerts"
}

resource "aws_cloudwatch_metric_alarm" "bedrock_slow" {
  alarm_name          = "wishifai-${var.candidate_number}-bedrock-slow"
  alarm_description   = "Bedrock bruker i snitt mer enn ${var.bedrock_latency_threshold_ms} ms per kall"
  namespace           = local.namespace
  metric_name         = "bedrock.duration.avg"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.bedrock_latency_threshold_ms
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}