output "ecr" {
  value = aws_ecr_repository.course_management_api_ecr
}

output "lb_endpoint" {
  value = aws_alb.application_load_balancer.dns_name

  description = "hit this url to access web server"
}

output "codebuild_test_security_group_id" {
  value = aws_security_group.codebuild-test-api-sg.id
}

output "env_ecs" {
  value = local.prod_creds
}