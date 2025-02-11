# Archive configuration for Lambda deployment package
data "archive_file" "lambda_zip" {
 # Specify zip format for the archive
 type        = "zip"
 # Path to the Lambda function source code
 source_file = "${path.module}/lambda/counter.py"
 # Output location for the created zip file
 # path.module refers to the directory containing this Terraform configuration
 output_path = "${path.module}/lambda/counter.zip"
}