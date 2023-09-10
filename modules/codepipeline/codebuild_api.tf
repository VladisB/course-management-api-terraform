resource "time_static" "time" {}

locals {
  tags = {
    Creator         = "Terraform"
    Environment     = var.stage
    Layer           = "API"
    Service         = "Codepipeline"
    CreationDate    = formatdate("YYYY-MM-DD", time_static.time.rfc3339)
  }
}

resource "aws_codebuild_project" "api_build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "${var.env_prefix}-course-management-api-build-${var.stage}"
  description    = "CodeBuild project for Course Management API ${var.stage} environment."
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild_role.arn

  tags           = local.tags

  artifacts {
    encryption_disabled    = false
    name                   = "${var.env_prefix}-course-management-api-build-${var.stage}"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = "buildspec.${var.stage}.yml"

    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "api_test" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "${var.env_prefix}-course-management-api-test-${var.stage}"
  description    = "CodeBuild project for Course Management API ${var.stage} environment."
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild_role.arn

  tags           = local.tags

  artifacts {
    encryption_disabled    = false
    name                   = "${var.env_prefix}-course-management-api-test-${var.stage}"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = "test-buildspec.${var.stage}.yml"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnets
    security_group_ids = [aws_security_group.codebuild-test-api-sg.id]
  }
}

resource "aws_codebuild_project" "api_migration" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "${var.env_prefix}-course-management-api-migration-${var.stage}"
  description    = "CodeBuild project for Course Management API ${var.stage} environment."
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild_role.arn

  tags           = local.tags

  artifacts {
    encryption_disabled    = false
    name                   = "${var.env_prefix}-course-management-api-migration-${var.stage}"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec = "migration-buildspec.${var.stage}.yml"
    
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnets
    security_group_ids = [aws_security_group.codebuild-test-api-sg.id]
  }
}

//TODO: move to a separate module/file
resource "aws_security_group" "codebuild-test-api-sg" {
    name = "${var.env_prefix}-test-stage-sg"
    vpc_id = var.vpc_id

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-test-stage-sg"
        Environment = "dev"
    }
}