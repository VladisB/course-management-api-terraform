locals {
  app_bucket_name = "course-management-${var.env_prefix}" // Bucket name for the api app

  #   ecr_repo_name = "demo-app-ecr-repo"

  #   demo_app_cluster_name        = "demo-app-cluster"
  availability_zones           = ["eu-east-1a", "eu-east-1b"]
  demo_app_task_famliy         = "demo-app-task"
  container_port               = 8080
  demo_app_task_name           = "demo-app-task"
  ecs_task_execution_role_name = "demo-app-task-execution-role"

  application_load_balancer_name = "cc-demo-app-alb"
  target_group_name              = "cc-demo-alb-tg"

  demo_app_service_name = "cc-demo-app-service"
}