# Configure Terraform for AWS provider
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
  region = "ap-south-2"
}

# Create Iam Group
resource "aws_iam_group" "devops_group" {
  name = "devops_group"
}

# Create IAM user
resource "aws_iam_user" "devops_user" {
  name  = "devops_user-pseu"
}

#  Create Iam group policy
# Define an IAM policy resource named "ec2_policy"
resource "aws_iam_policy" "ec2_policy" {
    # Set the name of the policy
    name        = "ec2_policy"
    # Set a description for the policy
    description = "Policy to allow EC2 actions"
    # Define the policy document using jsondecode
    policy      = jsonencode(
        {
            # Specify the policy version
            Version = "2012-10-17"
            # Define the statements for the policy
            Statement = [
                {
                    # Allow the specified actions
                    Effect = "Allow"
                    # List of EC2 actions permitted by this policy
                    Action = [
                        "ec2:DescribeInstances",
                        "ec2:StartInstances",
                        "ec2:StopInstances",
                        "ec2:TerminateInstances"
                    ]
                    # Apply the actions to all resources
                    Resource = "*"
                }
            ]
        }
    )
}

# Attach the policy to the IAM group
resource "aws_iam_group_policy_attachment" "devops_group_policy_attachment" {
  # Specify the group to which the policy will be attached
  group      = aws_iam_group.devops_group.name
  # Specify the policy ARN to attach
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Attach the IAM group to the user
resource "aws_iam_user_group_membership" "devops_user_group_membership" {
  # Specify the user to be added to the group
  user = aws_iam_user.devops_user.name
  # Specify the group to which the user will be added
  groups = [aws_iam_group.devops_group.name]
}

# Create an access key for the IAM user
resource "aws_iam_access_key" "devops_user_access_key" {
  # Specify the IAM user for whom the access key will be created
  user = aws_iam_user.devops_user.name
}