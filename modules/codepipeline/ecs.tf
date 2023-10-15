data "aws_secretsmanager_secret" "course_management" {
  name = "course-management-api/prod"
}

data "aws_secretsmanager_secret_version" "course_management" {
  secret_id = data.aws_secretsmanager_secret.course_management.id
}

resource "aws_ecs_cluster" "api_app_cluster" {
  name = var.api_app_cluster_name
}

resource "aws_ecs_task_definition" "api_app_task" {
  family = var.api_app_task_famliy

  container_definitions = jsonencode([
    {
      "name" : "${var.api_app_task_name}",
      "image" : "${var.ecr_repo_url}",
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : var.container_port,
          "hostPort" : var.container_port
        }
      ],
      "memory" : 512,
      "cpu" : 256,
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.example.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      },
      "environment" : local.ecs_container_envs
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256

  execution_role_arn = aws_iam_role.ecs_role_api.arn
}

resource "aws_cloudwatch_log_group" "example" {
  name = "/ecs/api_app"
}

resource "aws_iam_policy" "ecs_logging" {
  name        = "ECSTaskLogging"
  description = "Allows ECS tasks to push logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect   = "Allow",
        Resource = aws_cloudwatch_log_group.example.arn
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_logging" {
  policy_arn = aws_iam_policy.ecs_logging.arn

  role       = aws_iam_role.ecs_role_api.name
}

resource "aws_alb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  load_balancer_type = "application"

  subnets         = var.public_subnets
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_ecs_service" "api_app_service" {
  name            = var.api_app_service_name
  cluster         = aws_ecs_cluster.api_app_cluster.id
  task_definition = aws_ecs_task_definition.api_app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.api_app_task.family
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.public_subnets
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}

resource "aws_security_group" "service_security_group" {
  name = "service_security_group"

  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

