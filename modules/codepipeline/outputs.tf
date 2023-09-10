output "ecr" {
    value = aws_ecr_repository.course_management_api_ecr
}

output "codebuild_test_security_group_id" {
    value = aws_security_group.codebuild-test-api-sg.id
}