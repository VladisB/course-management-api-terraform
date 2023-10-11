resource "aws_codepipeline" "api_pipeline" {
  name     = "course-management-api-${var.stage}"
  role_arn = aws_iam_role.codepipeline_role.arn
  tags     = local.tags

  artifact_store {
    location = aws_s3_bucket.artifacts_codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "ConnectionArn" = aws_codestarconnections_connection.github.arn
        # "BranchName"           = var.stage == "prod" ? "main" : "develop"
        "BranchName"       = "develop" // NOTE: Temporary
        "FullRepositoryId" = "VladisB/course-management"
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

        "ProjectName" = aws_codebuild_project.api_build.name
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

  stage {
    name = "Test"

    action {
      category = "Test"
      configuration = {
        "ProjectName" = aws_codebuild_project.api_test.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Test"
      output_artifacts = [
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Approval"

    action {
      category = "Approval"
      configuration = {
        "CustomData" = "Approve or reject the change"
      }
      input_artifacts  = []
      name             = "Approval"
      output_artifacts = []
      owner            = "AWS"
      provider         = "Manual"
      run_order        = 1
      version          = "1"
    }
  }

  stage {
    name = "Migration"

    action {
      category = "Build" //NOTE: Deploy is unavailable in eu-west-1
      configuration = {
        "ProjectName" = aws_codebuild_project.api_migration.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]

      name = "Migration"

      output_artifacts = []

      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }

  # // Deploy to ECS
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ClusterName" = aws_ecs_cluster.api_app_cluster.name
        "ServiceName" = "course-management-api"
        "FileName"    = "imagedefinitions.json"
      }

      input_artifacts = ["BuildArtifact"]

      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "ECS"
      run_order        = 1
      version          = "1"
    }
  }

}

