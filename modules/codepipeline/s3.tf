resource "aws_s3_bucket" "artifacts_codepipeline" {
  bucket = "${var.env_prefix}artifacts-codepipeline-${var.stage}"

  tags = local.tags
}