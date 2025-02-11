# DynamoDB table configuration for visitor counter
resource "aws_dynamodb_table" "visitor_count" {
  # Table name for the visitor counter
  name           = "visitor-counter"
  # Use on-demand pricing model (pay per request)
  billing_mode   = "PAY_PER_REQUEST"
  # Primary key attribute name
  hash_key       = "id"
  
  # Define primary key attribute
  attribute {
    name = "id"     # Attribute name matching hash_key
    type = "S"      # String type attribute
  }

  # Resource tagging
  tags = {
    Environment = var.environment
    Project     = "cloud-resume-challenge"
  }
}

# Initialize DynamoDB table with counter item
resource "aws_dynamodb_table_item" "visitor_count" {
  # Reference the created table
  table_name = aws_dynamodb_table.visitor_count.name
  hash_key   = aws_dynamodb_table.visitor_count.hash_key

  # Initial counter item
  item = jsonencode({
    id = {
      S = "visitor_count"    # String type primary key
    }
    count = {
      N = "0"               # Number type counter, starting at 0
    }
  })

  # Prevent Terraform from updating the item after creation
  # This allows the counter to be modified outside of Terraform
  lifecycle {
    ignore_changes = [item]
  }
}