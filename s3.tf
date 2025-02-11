# Create S3 bucket for website hosting
resource "aws_s3_bucket" "website" {
  # Use domain name as bucket name
  bucket = var.domain_name

  # Resource tagging
  tags = {
    Environment = var.environment
    Project     = "cloud-resume-challenge"
  }
}

# Configure bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  # Set default page
  index_document {
    suffix = "index.html"
  }

  # Set error page
  error_document {
    key = "error.html"
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  # Prevent public ACLs
  block_public_acls       = true
  # Prevent public bucket policies
  block_public_policy     = true
  # Ignore any public ACLs
  ignore_public_acls      = true
  # Restrict public bucket access
  restrict_public_buckets = true
}

# Configure bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  
  # Policy allowing CloudFront to access objects
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        # Restrict access to specific CloudFront distribution
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
  # Ensure CloudFront distribution exists before creating policy
  depends_on = [aws_cloudfront_distribution.website]
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  
  versioning_configuration {
    # Enable versioning for backup and rollback capability
    status = "Enabled"
  }
}