resource "aws_s3_bucket" "images" {
  bucket        = "wishifai-${var.candidate_number}-images"
  force_destroy = true
}