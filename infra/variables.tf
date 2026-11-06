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