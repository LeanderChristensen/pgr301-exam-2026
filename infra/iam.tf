locals {
  account_id = "244530008913"
  model_id   = "anthropic.claude-sonnet-4-5-20250929-v1:0"
}

data "aws_iam_policy_document" "task_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_permissions" {
  statement {
    sid       = "UploadImages"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }

  statement {
    sid       = "DetectLabels"
    actions   = ["rekognition:DetectLabels"]
    resources = ["*"]
  }

  statement {
    sid     = "InvokeModel"
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:aws:bedrock:*:${local.account_id}:inference-profile/eu.${local.model_id}",
      "arn:aws:bedrock:*::foundation-model/${local.model_id}",
    ]
  }

  statement {
    sid       = "PublishMetrics"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "task" {
  name               = "wishifai-task-role-${var.candidate_number}"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}

resource "aws_iam_role_policy" "task" {
  name   = "wishifai-task-policy-${var.candidate_number}"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_permissions.json
}