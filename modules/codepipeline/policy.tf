resource "aws_iam_role" "codepipeline_role" {
  name = "${var.env_prefix}codepipeline-role-${var.stage}"
  tags = local.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codepipeline.amazonaws.com",
          "codebuild.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

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
        Effect    = "Allow",
        Action    = [
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
        Effect    = "Allow",
        Action    = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.artifacts_codepipeline.arn}",
          "${aws_s3_bucket.artifacts_codepipeline.arn}/*"
        ]
      }
    ]
  })
}

// Policy for codebuild to access to secrets manager
resource "aws_iam_policy" "codebuild_secrets_policy" {
  name        = "CodeBuildSecretsPolicy"
  description = "Allows CodeBuild to get access to Secrets Manager."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = "*"
      }
    ]
  })
}

// Policy for codebuild to access to ecr repository for code build
resource "aws_iam_policy" "codebuild_ecr_policy" {
    name="CodeBuildECRPolicy"
    description="Allows CodeBuild to get access to ECR repository."
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect="Allow",
                Action=[
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:CompleteLayerUpload",
                    "ecr:GetAuthorizationToken",
                    "ecr:InitiateLayerUpload",
                    "ecr:PutImage",
                    "ecr:UploadLayerPart"
                ],
                Resource="*"
            }
        ]
    }) 
}


resource "aws_iam_role_policy_attachment" "attach_codebuild_logs_policy" {
  role       = "codebuild-api-nodejs-role"
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_s3_policy" {
  role       = "codebuild-api-nodejs-role"
  policy_arn = aws_iam_policy.codebuild_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_secrets_policy" {
  role       = "codebuild-api-nodejs-role"
  policy_arn = aws_iam_policy.codebuild_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_ecr_policy" {
    role       = "codebuild-api-nodejs-role"
    policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
}
