# Define local variable for S3 origin identifier
locals {
  # Creates a unique identifier for the S3 origin using domain name
  s3_origin_id = "S3-${var.domain_name}"
}

# Configure Origin Access Control for secure S3 bucket access
resource "aws_cloudfront_origin_access_control" "website" {
  # Create unique name using domain
  name                              = "OAC-${var.domain_name}"
  description                       = "Origin Access Control for Resume Website"
  # Specify S3 as the origin type
  origin_access_control_origin_type = "s3"
  # Always sign requests to S3
  signing_behavior                  = "always"
  # Use SigV4 for request signing
  signing_protocol                  = "sigv4"
}

# CloudFront distribution configuration
resource "aws_cloudfront_distribution" "website" {
  # Enable the distribution
  enabled             = true
  # Enable IPv6 support
  is_ipv6_enabled     = true
  # Set index.html as the default root object
  default_root_object = "index.html"
  # Add custom domain name alias
  aliases             = [var.domain_name]

  # Origin configuration for S3 bucket
  origin {
    # Use regional domain name for better performance
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    # Link to Origin Access Control
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
    # Set origin ID using local variable
    origin_id               = local.s3_origin_id
  }

  # Default cache behavior settings
  default_cache_behavior {
    # Allow only GET and HEAD HTTP methods
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    # Force HTTPS for all requests
    viewer_protocol_policy = "redirect-to-https"
    # Enable compression for faster delivery
    compress              = true

    # Configure forwarded values
    forwarded_values {
      # Don't forward query strings
      query_string = false
      # Don't forward cookies
      cookies {
        forward = "none"
      }
    }

    # Cache TTL settings in seconds
    min_ttl                = 0      # Minimum time to live
    default_ttl            = 3600   # Default (1 hour)
    max_ttl                = 86400  # Maximum (24 hours)
  }

  # Use most cost-effective price class (US, Canada, Europe)
  price_class = "PriceClass_100"

  # Geographic restrictions
  restrictions {
    geo_restriction {
      # No geographic restrictions
      restriction_type = "none"
    }
  }

  # SSL/TLS certificate configuration
  viewer_certificate {
    # Use ACM certificate
    acm_certificate_arn      = aws_acm_certificate.website.arn
    # Use SNI for SSL (more cost-effective)
    ssl_support_method       = "sni-only"
    # Modern security protocol version
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Resource tagging
  tags = {
    Environment = var.environment
    Project     = "cloud-resume-challenge"
  }

  # Ensure certificate is validated before distribution creation
  depends_on = [aws_acm_certificate_validation.website]
}