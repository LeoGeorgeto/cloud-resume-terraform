# Domain name for the website infrastructure
variable "domain_name" {
 type        = string
 description = "The domain name for the website"
 # Default value for the domain
 default     = "leogeo-cloudresume.com"
}

# Environment tag for resource organization
variable "environment" {
 type        = string
 description = "Environment name for tagging"
 # Set default to production environment
 default     = "production"
}

# AWS region configuration
variable "region" {
 type        = string
 description = "AWS region"
 # Default to US East (N. Virginia)
 # Used for services requiring regional specification
 default     = "us-east-1"
}