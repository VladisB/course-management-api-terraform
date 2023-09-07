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
    # environment_variable {
    #   name  = "MYELIN_CODEBUILD_ENV"
    #   value = var.stage
    # }
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

  # source {
  # type            = "GITHUB"
  #   location        = "https://github.com/VladisB/course-management.git"
  #   git_clone_depth = 1
  # }
  source {
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

# resource "aws_codebuild_project" "api_build" {
#   name          = "api-build"
#   description   = "API Build Project"

#   service_role  = aws_iam_role.codebuild_role.arn

#   source {
#     type            = "GITHUB"
#     location        = "https://github.com/VladisB/course-management.git"
#     git_clone_depth = 1
#     # Note: The auth block is used to authenticate to private repos. For public repos, this isn't necessary.
#     # auth {
#     #   type     = "OAUTH"
#     #   resource = "YOUR_OAUTH_TOKEN" 
#     # }
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:5.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"
#   }
# }


# resource "aws_codepipeline" "api_pipeline" {
#   name          = "${var.env_prefix}-course-management-api-${var.stage}"
#   role_arn      = aws_iam_role.codepipeline_role.arn
#   tags          = local.tags

#   artifact_store {
#     location = aws_s3_bucket.artifacts_codepipeline.bucket
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       category = "Source"
#       configuration = {
#         "ConnectionArn"        = aws_codestarconnections_connection.github.arn 
#         "BranchName"           = var.stage
#         "FullRepositoryId"     = "VladisB/course-management"
#       }
#       input_artifacts = []
#       name            = "Source"
#       output_artifacts = [
#         "SourceArtifact",
#       ]
#       owner     = "AWS"
#       provider  = "CodeStarSourceConnection"
#       run_order = 1
#       version   = "1"
#     }
#   }
#   # stage {
#   #   name = "Build"

#   #   action {
#   #     category = "Build"
#   #     configuration = {
#   #       "EnvironmentVariables" = jsonencode(
#   #         [
#   #           {
#   #             name  = "environment"
#   #             type  = "PLAINTEXT"
#   #             value = var.stage
#   #           },
#   #         ]
#   #       )
#   #       "ProjectName" = "${var.env_prefix}myelin-app-api-build-${var.stage}"
#   #     }
#   #     input_artifacts = [
#   #       "SourceArtifact",
#   #     ]
#   #     name = "Build"
#   #     output_artifacts = [
#   #       "BuildArtifact",
#   #     ]
#   #     owner     = "AWS"
#   #     provider  = "CodeBuild"
#   #     run_order = 1
#   #     version   = "1"
#   #   }
#   # }

#   # stage {
#   #   name = "Test"

#   #   action {
#   #     category = "Test"
#   #     configuration = {
#   #       "ProjectName" = "${var.env_prefix}myelin-app-api-test-${var.stage}"
#   #     }
#   #     input_artifacts = [
#   #       "SourceArtifact",
#   #     ]
#   #     name = "Test"
#   #     output_artifacts = [
#   #     ]
#   #     owner     = "AWS"
#   #     provider  = "CodeBuild"
#   #     run_order = 1
#   #     version   = "1"
#   #   }
#   # }

#   # stage {
#   #   name = "Deploy"

#   #   action {
#   #     category = "Deploy"
#   #     configuration = {
#   #       "ApplicationName": data.terraform_remote_state.beanstalk.outputs.application_name,
#   #       "EnvironmentName": data.terraform_remote_state.beanstalk.outputs.environment_name
#   #     }
#   #     input_artifacts = [
#   #       "BuildArtifact",
#   #     ]
#   #     name             = "Deploy"
#   #     output_artifacts = []
#   #     owner            = "AWS"
#   #     provider         = "ElasticBeanstalk"
#   #     run_order        = 1
#   #     version          = "1"
#   #   }
#   # }
# }

