# Terraform configuration block
terraform {
  # Define required providers and versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"    # Official AWS provider
      version = "~> 5.0"           # Use version 5.x
    }
  }
}

# AWS provider configuration
provider "aws" {
  region = "us-east-1"    # Set AWS region to US East (N. Virginia)
}

# Create IAM user for CI/CD deployments
resource "aws_iam_user" "deployment_user" {
  name = "cloud-resume-deployer"
  # Tag for identification and documentation
  tags = {
    Description = "IAM user for Cloud Resume Challenge deployments"
  }
}

# Generate access keys for deployment user
resource "aws_iam_access_key" "deployer_key" {
  # Link to created IAM user
  user = aws_iam_user.deployment_user.name
}

# Define IAM policy for deployment permissions
resource "aws_iam_policy" "deployment_policy" {
  name        = "cloud-resume-deployment-policy"
  description = "Policy for Cloud Resume Challenge deployments"

  # Policy document granting necessary permissions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # Services required for the cloud resume challenge
        Action = [
          "s3:*",              # S3 bucket operations
          "cloudfront:*",      # CloudFront distribution management
          "route53:*",         # DNS management
          "acm:*",             # Certificate management
          "lambda:*",          # Lambda function operations
          "apigateway:*",      # API Gateway configuration
          "dynamodb:*",        # DynamoDB table operations
          "iam:*",             # IAM role management
          "cloudformation:*"   # CloudFormation stack operations
        ]
        Resource = "*"         # Apply to all resources
      }
    ]
  })
}

# Attach deployment policy to user
resource "aws_iam_user_policy_attachment" "deployer_policy_attach" {
  user       = aws_iam_user.deployment_user.name
  policy_arn = aws_iam_policy.deployment_policy.arn
}