# Specify the required Terraform provider for AWS
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"      # Use the official AWS provider from HashiCorp
            version = "~> 5.95"            # Specify the provider version constraint
        }
    }
}

# Configure the AWS provider with the desired region
provider "aws" {
    region = "ap-south-2"                  # Set AWS region to Asia Pacific (Hyderabad)
}

# Create an IAM user named 'devops_user'
resource "aws_iam_user" "devops_user" {
    name = "devops_user"                   # Name of the IAM user
}

# Create an IAM role named 'devops_role' and define its trust relationship
resource "aws_iam_role" "devops_role" {
    name               = "devops_role"     # Name of the IAM role
    assume_role_policy = jsonencode({      # Define the trust policy for the role
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"           # Allow the following principal to assume the role
                Principal = {
                    AWS = aws_iam_user.devops_user.arn  # Allow only the 'devops_user' to assume this role
                }
                Action = "sts:AssumeRole"  # Action allowed: sts:AssumeRole
            }
        ]
    })
}

# Attach the AWS managed policy 'AmazonS3FullAccess' to the 'devops_role'
resource "aws_iam_role_policy_attachment" "devops_role_policy_attachment" {
    role       = aws_iam_role.devops_role.name           # Attach to the 'devops_role'
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  # Policy granting full S3 access
}

# Create a custom IAM policy to allow 'devops_user' to assume 'devops_role'
resource "aws_iam_policy" "devops_assume_role_policy" {
    name        = "devops_assume_role_policy"             # Name of the custom policy
    description = "Policy to allow devops_user to assume the devops_role"  # Description
    policy      = jsonencode({                            # Policy document in JSON
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"                          # Allow the following action
                Action = "sts:AssumeRole"                 # Action: sts:AssumeRole
                Resource = aws_iam_role.devops_role.arn   # Resource: ARN of 'devops_role'
            }
        ]
    })
}

# Attach the custom assume role policy to the 'devops_user'
resource "aws_iam_user_policy_attachment" "devops_user_policy_attachment" {
    user       = aws_iam_user.devops_user.name            # Attach to 'devops_user'
    policy_arn = aws_iam_policy.devops_assume_role_policy.arn  # ARN of the custom policy
}

# Create an access key for the 'devops_user' for programmatic access
resource "aws_iam_access_key" "devops_user_access_key" {
    user = aws_iam_user.devops_user.name                  # Generate access key for 'devops_user'
}
