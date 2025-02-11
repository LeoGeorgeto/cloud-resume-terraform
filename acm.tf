# ACM Certificate configuration for SSL/TLS
resource "aws_acm_certificate" "website" {
  # Primary domain name for the certificate
  domain_name = var.domain_name
  
  # Adds wildcard subdomain support (e.g., *.example.com)
  subject_alternative_names = ["*.${var.domain_name}"]
  
  # Uses DNS validation instead of email validation
  validation_method = "DNS"

  # Resource tagging for organization
  tags = {
    Environment = var.environment
    Project     = "cloud-resume-challenge"
  }

  # Ensures new certificate is created before destroying old one
  # This prevents downtime during certificate updates
  lifecycle {
    create_before_destroy = true
  }
}

# Validates the ACM certificate using DNS records
resource "aws_acm_certificate_validation" "website" {
  # References the ARN of the certificate to validate
  certificate_arn = aws_acm_certificate.website.arn
  
  # Uses DNS records created by Route53 for validation
  # Dynamic block handles multiple validation records if present
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}