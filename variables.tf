variable "domain_name" {
  type        = string
  description = "The domain name for the website"
  default     = "leogeo-cloudresume.com"
}

variable "environment" {
  type        = string
  description = "Environment name for tagging"
  default     = "production"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}