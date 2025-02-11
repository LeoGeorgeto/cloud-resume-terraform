# Output the access key ID for the deployment user
output "access_key_id" {
 value = aws_iam_access_key.deployer_key.id    # Public identifier part of access key
}

# Output the secret access key for the deployment user
output "secret_access_key" {
 value     = aws_iam_access_key.deployer_key.secret
 sensitive = true    # Mark as sensitive to prevent displaying in logs
}

# Output the complete API endpoint URL for the visitor counter
output "api_url" {
 value       = "${aws_api_gateway_stage.visitor_api_stage.invoke_url}/count"
 description = "URL of the API Gateway endpoint"    # Full URL for accessing the counter API
}

# Output the CloudFront distribution domain
output "cloudfront_url" {
 value       = aws_cloudfront_distribution.website.domain_name
 description = "CloudFront Distribution Domain"    # Domain for accessing the website through CloudFront
}