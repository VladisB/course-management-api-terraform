resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role-${var.stage}"
  tags = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = [
            "codepipeline.amazonaws.com",
            "codebuild.amazonaws.com",
            "ecs-tasks.amazonaws.com" // Just added
          ]
        },
        Effect = "Allow",
      },
    ]
  })

}

resource "aws_iam_policy" "custom_ecs_full_access" {
  name        = "CustomEC2ContainerServiceFullAccess"
  description = "My custom policy that grants full access to Amazon ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecs:*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

// PassRole policy
resource "aws_iam_policy" "codepipeline_passrole_policy" {
  name        = "CodePipelinePassRolePolicy"
  description = "Allows CodePipeline to pass roles to other services."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

// Assigning the policy to the role
resource "aws_iam_role_policy_attachment" "attach_codepipeline_passrole_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_passrole_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_custom_ecs_policy" {
  policy_arn = aws_iam_policy.custom_ecs_full_access.arn
  role       = aws_iam_role.codepipeline_role.name
}

// add ecs_task_execution_role_policy
# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
#   role       = aws_iam_role.codepipeline_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
// Granting iam:PassRole Permission
# resource "aws_iam_role_policy_attachment" "codepipeline_role_policy" {
#   role       = aws_iam_role.codepipeline_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineCustomActionAccess"
# }

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-api-nodejs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Effect = "Allow",
      },
    ]
  })
}

resource "aws_iam_policy" "codebuild_logs_policy" {
  name        = "CodeBuildCloudWatchLogsPolicy"
  description = "Allows CodeBuild to write logs to CloudWatch Logs."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_s3_policy" {
  name        = "CodeBuildS3Policy"
  description = "Allows CodeBuild to get access to S3 bucket."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "${aws_s3_bucket.artifacts_codepipeline.arn}",
          "${aws_s3_bucket.artifacts_codepipeline.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_secrets_policy" {
  name        = "CodeBuildSecretsPolicy"
  description = "Allows CodeBuild to get access to Secrets Manager."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_ecr_policy" {
  name        = "CodeBuildECRPolicy"
  description = "Allows CodeBuild to get access to ECR repository."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_report_groups_policy" {
  name        = "CodeBuildReportGroupsPolicy"
  description = "Allows CodeBuild to get access to ReportGroups."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_network_interfaces_policy" {
  name        = "CodeBuildNetworkPolicy"
  description = "Allows CodeBuild to get access to Network."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterfacePermission"
        ],
        Resource = "*"
      },

    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_codebuild_logs_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_s3_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_secrets_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_ecr_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_report_groups_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_report_groups_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_network_interfaces_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_network_interfaces_policy.arn
}