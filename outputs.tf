output "access_key_id" {
  value = aws_iam_access_key.deployer_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.deployer_key.secret
  sensitive = true
}

output "api_url" {
  value = "${aws_api_gateway_stage.visitor_api_stage.invoke_url}/count"
  description = "URL of the API Gateway endpoint"
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.website.domain_name
  description = "CloudFront Distribution Domain"
}