# Specify the required Terraform provider block
terraform {
    # Define required providers
    required_providers {
        # Specify AWS provider source and version
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.95"
        }
    }
}

# Configure the AWS provider
provider "aws" {
    # Set the AWS region to ap-south-1
    region = "ap-south-1"
}

# Create an IAM group resource
resource "aws_iam_group" "example_group" {
    # Set the IAM group name to "example-group"
    name = "example-group"
}

# Define an IAM policy document data source
data "aws_iam_policy_document" "example_policy" {
    # Add a statement to the policy document
    statement {
        # Allow the following S3 actions
        actions = [
            "s3:ListBucket",
            "s3:GetObject"
        ]
        # Set the effect to Allow
        effect    = "Allow"
        # Apply to all resources
        resources = ["*"]
    }
}

# Create an IAM policy resource
resource "aws_iam_policy" "s3_policy" {
    # Set the policy name to "allow_s3_policy"
    name        = "allow_s3_policy"
    # Provide a description for the policy
    description = "An example IAM policy for S3"
    # Use the generated policy document as the policy
    policy      = data.aws_iam_policy_document.example_policy.json
}

# Attach the IAM policy to the IAM group
resource "aws_iam_group_policy_attachment" "example_attachment" {
    # Specify the group name to attach the policy to (must use name, not arn)
    group      = aws_iam_group.example_group.name
    # Specify the ARN of the policy to attach
    policy_arn = aws_iam_policy.s3_policy.arn
}
