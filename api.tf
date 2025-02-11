# Lambda function configuration for the visitor counter
resource "aws_lambda_function" "visitor_counter" {
  # Specifies the deployment package for the Lambda function
  filename         = data.archive_file.lambda_zip.output_path
  # Hash of the function's deployment package contents
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  # Name of the Lambda function
  function_name    = "visitor-counter"
  # IAM role that Lambda assumes to execute
  role            = aws_iam_role.lambda_exec.arn
  # Entry point for the Lambda function
  handler         = "counter.lambda_handler"
  # Python runtime version
  runtime         = "python3.9"

  # Environment variables available to the function
  environment {
    variables = {
      # DynamoDB table name for storing visitor count
      DYNAMODB_TABLE = aws_dynamodb_table.visitor_count.name
    }
  }

  tags = {
    Environment = var.environment
    Project     = "cloud-resume-challenge"
  }
}

# IAM role for Lambda execution permissions
resource "aws_iam_role" "lambda_exec" {
  name = "visitor_counter_lambda_role"

  # Trust policy allowing Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy defining Lambda permissions
resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "visitor_counter_lambda_policy"
  role = aws_iam_role.lambda_exec.id

  # Policy document granting DynamoDB and CloudWatch Logs permissions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # DynamoDB permissions for visitor counter operations
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.visitor_count.arn
      },
      {
        # CloudWatch Logs permissions for Lambda function logging
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# API Gateway configuration for exposing the Lambda function
resource "aws_api_gateway_rest_api" "visitor_api" {
  name = "visitor-counter-api"

  tags = {
    Environment = var.environment
    Project     = "cloud-resume-challenge"
  }
}

# API Gateway resource defining the API endpoint path
resource "aws_api_gateway_resource" "visitor_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "count"  # Creates /count endpoint
}

# HTTP GET method configuration for the API
resource "aws_api_gateway_method" "visitor_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.visitor_api_resource.id
  http_method   = "GET"
  authorization = "NONE"  # Public endpoint, no authorization required
}

# Integration between API Gateway and Lambda function
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_api_resource.id
  http_method = aws_api_gateway_method.visitor_api_method.http_method

  # Configure Lambda proxy integration
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.visitor_counter.invoke_arn
}

# Permission allowing API Gateway to invoke Lambda function
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_api.execution_arn}/*/*"
}

# API Gateway deployment configuration
resource "aws_api_gateway_deployment" "visitor_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id

  # Ensure the Lambda integration exists before deployment
  depends_on = [
    aws_api_gateway_integration.lambda
  ]

  # Ensure new deployment is created before destroying old one
  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage configuration
resource "aws_api_gateway_stage" "visitor_api_stage" {
  deployment_id = aws_api_gateway_deployment.visitor_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  stage_name    = "prod"  # Production stage
}

# CORS configuration - OPTIONS method
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.visitor_api_resource.id
  http_method   = "OPTIONS"  # Required for CORS preflight requests
  authorization = "NONE"
}

# CORS - Method response configuration
resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_api_resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  # Define CORS headers in response
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# CORS - Integration configuration for OPTIONS method
resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_api_resource.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"  # Mock integration for OPTIONS requests

  # Return 200 status code for OPTIONS requests
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS - Integration response configuration
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_api_resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code

  # Set CORS headers in the response
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"  # Allow all origins
  }

  depends_on = [aws_api_gateway_integration.options]
}
