# Create a Route53 hosted zone for the domain
resource "aws_route53_zone" "main" {
 # Domain name for the hosted zone
 name = var.domain_name

 # Resource tagging
 tags = {
   Environment = var.environment
   Project     = "cloud-resume-challenge"
 }
}

# Create an A record pointing the domain to CloudFront
resource "aws_route53_record" "website_a" {
 # Reference the created hosted zone
 zone_id = aws_route53_zone.main.zone_id
 # Domain name for the record
 name    = var.domain_name
 # A record type for IPv4 addresses
 type    = "A"

 # Alias record configuration (pointing to CloudFront)
 alias {
   # CloudFront distribution domain name
   name                   = aws_cloudfront_distribution.website.domain_name
   # CloudFront's hosted zone ID
   zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
   # Skip health checks for CloudFront
   evaluate_target_health = false
 }
}

# Create DNS records for ACM certificate validation
resource "aws_route53_record" "cert_validation" {
 # Create records for each domain validation option
 for_each = {
   # Transform validation options into a map
   for dvo in aws_acm_certificate.website.domain_validation_options : dvo.domain_name => {
     name   = dvo.resource_record_name
     record = dvo.resource_record_value
     type   = dvo.resource_record_type
   }
 }

 # Allow overwriting existing records
 allow_overwrite = true
 # DNS record name from validation options
 name            = each.value.name
 # Validation record value
 records         = [each.value.record]
 # Short TTL for quick validation
 ttl             = 60
 # Record type from validation options
 type            = each.value.type
 # Reference the created hosted zone
 zone_id         = aws_route53_zone.main.zone_id
}