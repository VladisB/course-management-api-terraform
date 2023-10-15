variable "env_prefix" {}
variable "stage" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "aws_region" {}
variable "db_secret_id" {}

variable "ecs_task_family" {
  default = "course-management-api"
}

variable "api_app_cluster_name" {
  description = "ECS Cluster Name"
  type        = string
}

variable "availability_zones" {
  description = "eu-east-1 AZs"
  type        = list(string)

  default = ["eu-east-1a", "eu-east-1b"]
}

variable "api_app_task_famliy" {
  description = "ECS Task Family"
  type        = string

  default = "course-management-api"
}

variable "ecr_repo_url" {
  description = "ECR Repo URL"
  type        = string

  default = "544564125819.dkr.ecr.eu-west-1.amazonaws.com/cm-api-prod:latest"
}

variable "container_port" {
  description = "Container Port"
  type        = number

  default = 8080
}

variable "api_app_task_name" {
  description = "ECS Task Name"
  type        = string

  default = "course-management-api"
}

variable "ecs_task_execution_role_name" {
  description = "ECS Task Execution Role Name"
  type        = string

  # default = "cm-api-task-execution-role-${var.env_prefix}"
  default = "cm-api-task-execution-role-dev"
}

variable "application_load_balancer_name" {
  description = "ALB Name"
  type        = string
}

variable "target_group_name" {
  description = "ALB Target Group Name"
  type        = string
}

variable "api_app_service_name" {
  description = "ECS Service Name"
  type        = string

  default = "course-management-api"
}