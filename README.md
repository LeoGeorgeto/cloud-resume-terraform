# Cloud Resume Infrastructure as Code (IaC)

## Overview
This repository contains the Infrastructure as Code (IaC) implementation for the **Cloud Resume Challenge** using **Terraform**. It provisions and manages a complete AWS infrastructure for hosting a static website with a serverless visitor counter.

## Architecture
The infrastructure consists of the following components:

- **S3**: Static website hosting
- **CloudFront**: Content delivery and HTTPS
- **Route53**: DNS management
- **ACM**: SSL/TLS certification
- **Lambda** & **API Gateway**: Serverless visitor counter
- **DynamoDB**: Visitor count storage
- **IAM**: Security and access management

## Prerequisites
Ensure you have the following before getting started:

- An AWS Account
- **Terraform** version 1.0.0 or higher
- **AWS CLI** installed and configured
- A domain name registered in **Route53**

## Directory Structure

```
cloud-resume-terraform/
├── lambda/                 # Lambda function code
│   ├── counter.py         # Visitor counter implementation
│   └── counter.zip        # Deployment package
├── acm.tf                 # SSL certificate configuration
├── api.tf                 # API Gateway and Lambda configuration
├── cloudfront.tf          # CDN configuration
├── data.tf                # Data sources
├── dynamodb.tf            # Database configuration
├── main.tf                # Provider configuration and IAM roles
├── outputs.tf             # Output definitions
├── route53.tf             # DNS configuration
├── s3.tf                  # Static website bucket configuration
└── variables.tf           # Variable definitions
```

## Features
- **Serverless Architecture**: Built on AWS serverless services.
- **SSL/TLS Security**: Enforced HTTPS via CloudFront and ACM.
- **Content Delivery Network**: Fast, globally distributed access to the website.
- **Automated DNS Management**: Managed with Route53.
- **Visitor Analytics**: Tracks visitor counts using Lambda and DynamoDB.
- **Infrastructure as Code**: Fully defined in Terraform for reproducibility.
- **Access Control and Security**: Implements least privilege access policies.

---

## Quick Start

Follow these steps to deploy the infrastructure:

1. **Clone the repository**:

   ```bash
   git clone [repository-url]
   cd cloud-resume-terraform
   ```

2. **Update variables**:

   Edit `variables.tf` or create a `terraform.tfvars` file with your configuration:

   ```hcl
   domain_name  = "your-domain.com"
   environment  = "production"
   region       = "us-east-1"
   ```

3. **Initialize Terraform**:

   ```bash
   terraform init
   ```

4. **Review the execution plan**:

   ```bash
   terraform plan
   ```

5. **Apply the configuration**:

   ```bash
   terraform apply
   ```

---

## Security

### Access Management
- **S3 bucket** access is restricted to CloudFront.
- **HTTPS** is enforced for all traffic.
- **IAM roles** are configured with the least privilege principle.
- **Public access** is blocked on the S3 bucket.
- **API Gateway** includes CORS configuration.

---

## Resource Management

### Created Resources
- S3 Bucket (Static website hosting)
- CloudFront Distribution
- ACM Certificate
- Route53 DNS Records
- Lambda Function
- DynamoDB Table
- API Gateway
- IAM Roles and Policies

### State Management
- The Terraform state file is stored locally by default.
- For production environments, consider:
  - Remote state storage (e.g., S3)
  - State locking (e.g., DynamoDB)
  - State encryption

---

## Maintenance

### Updates
- **To update the infrastructure**:
  ```bash
  terraform plan
  terraform apply
  ```

- **To destroy the infrastructure**:
  ```bash
  terraform destroy
  ```

### Monitoring
- **CloudWatch Logs**: Monitor the Lambda function.
- **CloudFront Access Logs** (optional): Track CDN activity.
- **DynamoDB Metrics**: Monitor database performance.

---

## Best Practices Implemented

- Infrastructure as Code (IaC)
- Version Control
- Modular Design
- Least Privilege Access
- Resource Tagging
- Error Handling
- CORS Security
- SSL/TLS Encryption

---

## Known Limitations

- Region-specific implementation (**us-east-1**)
- Single environment configuration
- Local Terraform state storage (by default)

