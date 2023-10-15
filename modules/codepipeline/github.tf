resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection-${var.stage}"
  provider_type = "GitHub"
  tags          = local.tags
}
