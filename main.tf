terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# IAM User for deployments
resource "aws_iam_user" "deployment_user" {
  name = "cloud-resume-deployer"
  tags = {
    Description = "IAM user for Cloud Resume Challenge deployments"
  }
}

# Access key for the IAM user
resource "aws_iam_access_key" "deployer_key" {
  user = aws_iam_user.deployment_user.name
}

# IAM policy for deployment permissions
resource "aws_iam_policy" "deployment_policy" {
  name        = "cloud-resume-deployment-policy"
  description = "Policy for Cloud Resume Challenge deployments"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "cloudfront:*",
          "route53:*",
          "acm:*",
          "lambda:*",
          "apigateway:*",
          "dynamodb:*",
          "iam:*",
          "cloudformation:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "deployer_policy_attach" {
  user       = aws_iam_user.deployment_user.name
  policy_arn = aws_iam_policy.deployment_policy.arn
}