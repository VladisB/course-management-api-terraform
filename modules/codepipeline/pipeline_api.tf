resource "aws_codepipeline" "api_pipeline" {
  name          = "${var.env_prefix}-course-management-api-${var.stage}"
  role_arn      = aws_iam_role.codepipeline_role.arn
  tags          = local.tags

  artifact_store {
    location = aws_s3_bucket.artifacts_codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "ConnectionArn"        = aws_codestarconnections_connection.github.arn 
        "BranchName"           = var.stage
        "FullRepositoryId"     = "VladisB/course-management"
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.stage
            },
          ]
        )
        "ProjectName" = "${var.env_prefix}-course-management-api-build-${var.stage}"
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }

  # stage {
  #   name = "Test"

  #   action {
  #     category = "Test"
  #     configuration = {
  #       "ProjectName" = "${var.global_prefix}myelin-app-api-test-${var.stage}"
  #     }
  #     input_artifacts = [
  #       "SourceArtifact",
  #     ]
  #     name = "Test"
  #     output_artifacts = [
  #     ]
  #     owner     = "AWS"
  #     provider  = "CodeBuild"
  #     run_order = 1
  #     version   = "1"
  #   }
  # }

  # stage {
  #   name = "Deploy"

  #   action {
  #     category = "Deploy"
  #     configuration = {
  #       "ApplicationName": data.terraform_remote_state.beanstalk.outputs.application_name,
  #       "EnvironmentName": data.terraform_remote_state.beanstalk.outputs.environment_name
  #     }
  #     input_artifacts = [
  #       "BuildArtifact",
  #     ]
  #     name             = "Deploy"
  #     output_artifacts = []
  #     owner            = "AWS"
  #     provider         = "ElasticBeanstalk"
  #     run_order        = 1
  #     version          = "1"
  #   }
  # }
}

