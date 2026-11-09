variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "candidate_number" {
  description = "Exam candidate number"
  type        = string
  default     = "4"
}

variable "image_tag" {
  description = "Image tag in ECR (commit SHA)"
  type        = string
}

variable "bedrock_latency_threshold_ms" {
  description = "Average Bedrock call time in ms that triggers the alarm"
  type        = number
  default     = 20000
}