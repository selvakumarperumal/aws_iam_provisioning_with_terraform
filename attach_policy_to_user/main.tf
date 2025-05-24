# Configure Terraform to use the AWS provider
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"      # Specifies the source of the AWS provider
            version = "~> 5.95"            # Specifies the version constraint for the AWS provider
        }
    }
}

# Configure the AWS provider with the desired region
provider "aws" {
    region = "ap-south-2"                  # Sets the AWS region to ap-south-2 (Asia Pacific - Hyderabad)
}

# Create an IAM User named 'dev_user'
resource "aws_iam_user" "dev_user" {
    name = "dev_user"                      # The name of the IAM user to create
}

# Define a custom IAM policy document for the user with multiple statements
data "aws_iam_policy_document" "dev_user_policy" {
    # Statement 1: Allow listing all S3 buckets
    statement {
        effect    = "Allow"                        # Grants permission
        actions   = ["s3:ListAllMyBuckets"]        # Allows listing all S3 buckets
        resources = ["*"]                          # Applies to all resources
    }

    # Statement 2: Allow describing EC2 instances
    statement {
        effect    = "Allow"                        # Grants permission
        actions   = ["ec2:DescribeInstances"]      # Allows describing EC2 instances
        resources = ["*"]                          # Applies to all resources
    }

    # Statement 3: Deny deleting any IAM user
    statement {
        effect    = "Deny"                         # Explicitly denies permission
        actions   = ["iam:DeleteUser"]             # Denies deleting IAM users
        resources = ["*"]                          # Applies to all resources
    }
}

# Create a custom IAM policy using the above policy document
resource "aws_iam_policy" "dev_user_policy" {
    name        = "dev_user_policy"                        # The name of the IAM policy
    description = "A custom policy for dev user"           # A description for the policy
    policy      = data.aws_iam_policy_document.dev_user_policy.json # The policy document in JSON format
}

# Attach the custom policy to the IAM user
resource "aws_iam_user_policy_attachment" "dev_user_policy_attachment" {
    user       = aws_iam_user.dev_user.name              # The IAM user to attach the policy to
    policy_arn = aws_iam_policy.dev_user_policy.arn      # The ARN of the policy to attach
}

# Create an IAM Access Key for the user
resource "aws_iam_access_key" "dev_user_access_key" {
    user = aws_iam_user.dev_user.name                  # The IAM user to create the access key for
}
# Output the IAM user's access key ID and secret access key
output "dev_user_access_key_id" {
    value = aws_iam_access_key.dev_user_access_key.id  # Outputs the access key ID
}
output "dev_user_secret_access_key" {
    value     = aws_iam_access_key.dev_user_access_key.secret # Outputs the secret access key
    sensitive = true  # Marks the output as sensitive to avoid displaying it in logs
}