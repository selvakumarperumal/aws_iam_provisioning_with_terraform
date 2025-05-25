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
  region = "ap-south-2" # Change this to your desired AWS region, e.g., "ap-south-2" for Hyderabad
}

# Create Trust Policy for the IAM Role
data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name               = "EC2InstanceRole"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

# Cretae an IAM Policy document for S3 access
# This policy grants permissions to list, get, put, and delete objects in S3.
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["*"] # Adjust this to specific S3 bucket ARNs if needed
    # You can specify specific S3 bucket ARNs or object ARNs in the resources block.
    # Examples:
    # resources = ["arn:aws:s3:::my-bucket"]                        # Access to the bucket itself
    # resources = ["arn:aws:s3:::my-bucket/*"]                     # Access to all objects in the bucket
    # resources = [
    #   "arn:aws:s3:::my-bucket",
    #   "arn:aws:s3:::my-bucket/*"
    # ]                                                            # Access to both bucket and all objects
    effect    = "Allow"
  }
}

# Create IAM Policy for S3 access
resource "aws_iam_policy" "s3_policy" {
  name        = "EC2S3AccessPolicy"
  description = "Policy to allow EC2 instances to access S3 buckets"
  policy      = data.aws_iam_policy_document.s3_policy.json
}

# Attach the S3 policy to the EC2 role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
