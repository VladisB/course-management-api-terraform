locals {
  app_bucket_name = "course-management-${var.env_prefix}" // Bucket name for the api app

  availability_zones           = ["eu-east-1a", "eu-east-1b"]
  api_app_task_famliy         = "api-app-task"
  container_port               = 8080
  api_app_task_name           = "api-app-task"
  ecs_task_execution_role_name = "api-app-task-execution-role"

  application_load_balancer_name = "cc-api-app-alb"
  target_group_name              = "cc-api-alb-tg"

  api_app_service_name = "cc-api-app-service"

  prod_creds = jsondecode(data.aws_secretsmanager_secret_version.course_management.secret_string)

  ecs_container_envs = [
  # Application specific environment variables
  { name  = "APP_ACCESS_TOKEN_EXPIRES_IN", value = local.prod_creds.APP_ACCESS_TOKEN_EXPIRES_IN },
  { name  = "APP_JWT", value = local.prod_creds.APP_JWT },
  { name  = "APP_PORT", value = local.prod_creds.APP_PORT },
  { name  = "APP_REFRESH_TOKEN_EXPIRES_IN", value = local.prod_creds.APP_REFRESH_TOKEN_EXPIRES_IN },
  { name  = "APP_UPLOAD_FILE_SIZE_LIMIT_MB", value = local.prod_creds.APP_UPLOAD_FILE_SIZE_LIMIT_MB },
  { name  = "APP_UPLOAD_RATE_LIMIT", value = local.prod_creds.APP_UPLOAD_RATE_LIMIT },
  { name  = "APP_UPLOAD_RATE_LIMIT_TTL", value = local.prod_creds.APP_UPLOAD_RATE_LIMIT_TTL },
  
  # AWS S3 specific environment variables
  { name  = "AWS_ACCESS_KEY_ID", value = local.prod_creds.AWS_ACCESS_KEY_ID },
  { name  = "AWS_APP_BUCKET_NAME", value = local.prod_creds.AWS_APP_BUCKET_NAME },
  { name  = "AWS_S3_REGION", value = local.prod_creds.AWS_S3_REGION },
  { name  = "AWS_S3_URL_EXPIRES_IN_MIN", value = local.prod_creds.AWS_S3_URL_EXPIRES_IN_MIN },
  { name  = "AWS_SECRET_ACCESS_KEY", value = local.prod_creds.AWS_SECRET_ACCESS_KEY },
  
  # Database specific environment variables
  { name  = "DB_TYPE", value = "postgres" },
  { name  = "PG_DATABASE", value = local.prod_creds.PG_DATABASE },
  { name  = "PG_HOST", value = local.prod_creds.PG_HOST },
  { name  = "PG_PASSWORD", value = local.prod_creds.PG_PASSWORD },
  { name  = "PG_PORT", value = local.prod_creds.PG_PORT },
  { name  = "PG_USER", value = local.prod_creds.PG_USER },
  
  # Other environment variables
  { name  = "NODE_ENV", value = local.prod_creds.NODE_ENV }
]
}