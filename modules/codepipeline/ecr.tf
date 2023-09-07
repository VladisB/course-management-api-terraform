resource "aws_ecr_repository" "course_management_api_ecr" {
    name = "${var.env_prefix}-course-management-api"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = false
    }

    tags = local.tags
}