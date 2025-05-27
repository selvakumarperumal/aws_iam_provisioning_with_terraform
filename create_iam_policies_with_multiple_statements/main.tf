# Configure Terraform to use the AWS provider
terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.95"
        }
    }
}

# Configure the AWS provider
provider "aws" {
region = "ap-south-2" # Change to your desired region
}

# Create Multiple Statement Iam Policy Document
data "aws_iam_policy_document" "multiple_statements" {
  statement {
    actions = ["s3:ListBucket"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    actions = ["s3:GetObject"]
    resources = ["*"]
    effect = "Allow"
  }
  statement {
    actions = ["s3:PutObject"]
    resources = ["*"]
    effect = "Allow"
  }
}

# Create IAM Policy using the policy document
resource "aws_iam_policy" "multiple_statements_policy" {
  name        = "MultipleStatementsPolicy"
  description = "A policy with multiple statements for S3 access"
  policy      = data.aws_iam_policy_document.multiple_statements.json
}