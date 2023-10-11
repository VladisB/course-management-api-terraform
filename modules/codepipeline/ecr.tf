resource "aws_ecr_repository" "course_management_api_ecr" {
  name                 = "cm-api-${var.stage}"
  image_tag_mutability = "MUTABLE"
  tags                 = local.tags

  image_scanning_configuration {
    scan_on_push = false
  }
}