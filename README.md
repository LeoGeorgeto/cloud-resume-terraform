# **Cloud Resume Challenge - Terraform Infrastructure**

A fully automated, serverless infrastructure for a Cloud Resume Challenge project, built with **Terraform**, **AWS Lambda**, **DynamoDB**, **API Gateway**, **CloudFront**, and **S3**. This project provides a scalable and cost-efficient solution for tracking visitor counts on a static website.

---

## 🚀 **Features**

- **Infrastructure as Code (IaC)**: All cloud resources are provisioned using **Terraform**.
- **Serverless Backend**: Uses **AWS Lambda** and **DynamoDB** to store and manage visitor counts.
- **API Gateway**: Exposes a RESTful API endpoint for client-side interaction.
- **CloudFront & S3**: Implements a **CDN and static website hosting** for performance optimization.
- **SSL/TLS Security**: Integrated **ACM certificates** for HTTPS security.
- **Automated Deployments**: Uses **IAM roles** and **CI/CD IAM permissions** for automated deployments.
- **CORS Configuration**: Ensures cross-origin resource sharing for frontend API calls.

---

## 📂 **Project Structure**

```
cloud-resume-terraform/
│
├── .terraform/                    # Terraform state and provider files
├── lambda/                        # Source code for AWS Lambda function
│   ├── counter.py                 # Python function for visitor count
│   ├── counter.zip                # Zipped package for Lambda deployment
├── terraform/                      # Terraform configuration files
│   ├── acm.tf                      # SSL/TLS certificate configuration
│   ├── api.tf                      # API Gateway configuration
│   ├── cloudfront.tf               # CloudFront CDN configuration
│   ├── data.tf                     # Data sources
│   ├── dynamodb.tf                 # DynamoDB table for visitor counter
│   ├── main.tf                     # Core Terraform configurations
│   ├── outputs.tf                  # Terraform output values
│   ├── route53.tf                  # Route53 DNS configuration
│   ├── s3.tf                       # S3 bucket for website hosting
│   ├── variables.tf                 # Terraform variables
│   ├── terraform.tfstate            # Terraform state file
│   ├── terraform.tfstate.backup     # Terraform state backup
├── .gitignore                      # Git ignore file
├── README.md                       # Project documentation
```

---

## 🛠 **Technologies Used**

### **AWS Services**
- **AWS Lambda** – Serverless compute to process visitor counts.
- **Amazon DynamoDB** – NoSQL database to store visitor counts.
- **Amazon API Gateway** – RESTful API for client-side interaction.
- **Amazon S3** – Static website hosting for the frontend.
- **AWS CloudFront** – Content Delivery Network (CDN) for global access.
- **AWS Certificate Manager (ACM)** – Manages SSL/TLS certificates.
- **AWS IAM** – Role-based access control and security policies.
- **Amazon Route 53** – DNS management for custom domain configuration.

### **Infrastructure as Code (IaC)**
- **Terraform** – Manages all cloud resources programmatically.

### **Backend Development**
- **Python (boto3)** – AWS SDK for interacting with DynamoDB and Lambda.

---

## 🔧 **Setup and Deployment**

### **Prerequisites**

Ensure you have the following installed:
- **Terraform (>= v1.0.0)** – Infrastructure provisioning tool.
- **AWS CLI** – Command-line tool to manage AWS services.
- **Python 3.9+** – Required for Lambda function development.
- **Git** – Version control system.

### **1. Clone the Repository**
```bash
git clone <repository-url>
cd cloud-resume-terraform
```

### **2. Configure AWS Credentials**
Ensure you have AWS credentials configured in your environment.
```bash
aws configure
```

### **3. Initialize Terraform**
```bash
terraform init
```

### **4. Plan Infrastructure Deployment**
```bash
terraform plan
```

### **5. Deploy Infrastructure**
```bash
terraform apply --auto-approve
```

### **6. Verify Deployment**
After a successful deployment, Terraform will output the following values:
- **API URL:** The API Gateway endpoint for visitor count.
- **CloudFront URL:** The distribution domain for the frontend.

```bash
echo $(terraform output api_url)
echo $(terraform output cloudfront_url)
```

---

## 📦 **Available Terraform Resources**

| Resource        | Description                                       |
|----------------|---------------------------------------------------|
| `aws_lambda_function` | Deploys the visitor counter function.       |
| `aws_dynamodb_table`  | Stores visitor count data.                  |
| `aws_api_gateway_rest_api` | Creates REST API for frontend access. |
| `aws_cloudfront_distribution` | Serves the frontend securely.     |
| `aws_s3_bucket` | Hosts the frontend files.                        |
| `aws_route53_record` | Manages domain DNS settings.                |
| `aws_acm_certificate` | Enables SSL/TLS security.                 |

---

## 🚨 **Troubleshooting**

### **Common Issues & Fixes**
| Issue | Solution |
|--------|----------|
| `terraform init` fails | Ensure AWS CLI is configured properly. Run `aws configure`. |
| `terraform apply` fails | Check for typos in variable values and ensure AWS permissions are correct. |
| API Gateway not responding | Verify the `terraform output api_url` and test the endpoint using Postman or curl. |
| CloudFront updates not reflecting | Invalidate the cache using `aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"`. |

---

## 📝 **License**

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 🙌 **Acknowledgments**

- Inspired by the **Cloud Resume Challenge** by Forrest Brazeal.
- Built using **Terraform** and **AWS services** for hands-on cloud experience.

---

## 👨‍💻 **Author**

**Leonardo Georgeto**  
[LinkedIn](https://linkedin.com/in/georgetol) | [GitHub](https://github.com/LeoGeorgeto)
