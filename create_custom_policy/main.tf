# Configure Terraform to use the AWS provider
terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.95"
        }
    }
}

# COnfigure the AWS provider
provider "aws" {
    region = "us-east-1"
}

# Create Custom IAM Policy
resource "aws_iam_policy" "custom_policy" {
    name        = "CustomPolicy"
    description = "A custom policy for specific permissions"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:ListBucket",
                    "s3:GetObject"
                ]
                Resource = "*"
            }
        ]
    })
}
