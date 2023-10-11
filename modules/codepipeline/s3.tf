resource "aws_s3_bucket" "artifacts_codepipeline" {
  bucket = "cm-api-artifacts-${var.env_prefix}"

  tags = local.tags
}