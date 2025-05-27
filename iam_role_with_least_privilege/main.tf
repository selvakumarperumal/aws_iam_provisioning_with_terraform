# ----------------------------------------------------------
# Configure Terraform to use the AWS provider
# ----------------------------------------------------------
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"   # Specifies the AWS provider source (official HashiCorp AWS provider)
            version = "~> 5.95"         # Specifies the provider version constraint (compatible with 5.95.x releases)
        }
    }
}

# ----------------------------------------------------------
# Configure the AWS provider
# ----------------------------------------------------------
provider "aws" {
    region = "ap-south-2"           # Set the AWS region for resource creation (Asia Pacific - Hyderabad)
}

# ----------------------------------------------------------
# Create an IAM role for the EC2 instance with least privilege
# ----------------------------------------------------------
resource "aws_iam_role" "ec2_role" {
    name = "ec2_instance_role"      # Name of the IAM role

    # Define the trust relationship policy document
    assume_role_policy = jsonencode({
        Version = "2012-10-17"      # Policy language version
        Statement = [
            {
                Action = "sts:AssumeRole"         # Allows EC2 to assume this role
                Effect = "Allow"                  # Allow the action
                Principal = {
                    Service = "ec2.amazonaws.com"   # Restricts assumption to EC2 service only
                }
            }
        ]
    })
}

# ----------------------------------------------------------
# Create an IAM policy document for the EC2 role
# ----------------------------------------------------------
data "aws_iam_policy_document" "ec2_policy" {
    # Statement to allow listing S3 buckets and getting objects
    statement {
        actions = [
            "s3:ListBucket",    # Allows listing all S3 buckets
            "s3:GetObject"      # Allows reading objects from S3
        ]
        effect = "Allow"        # Allow the specified actions
        resources = ["*"]       # Applies to all S3 resources (can be restricted further for least privilege)
    }

    # Statement to allow putting objects into S3
    statement {
        actions = [
            "s3:PutObject"      # Allows uploading objects to S3
        ]
        effect = "Allow"        # Allow the specified action
        resources = ["*"]       # Applies to all S3 resources (can be restricted further for least privilege)
    }
}

# ----------------------------------------------------------
# Attach the policy to the IAM role as an inline policy
# ----------------------------------------------------------
resource "aws_iam_role_policy" "ec2_policy" {
    name   = "ec2_instance_policy"                  # Name of the inline policy
    role   = aws_iam_role.ec2_role.id               # Attach to the created IAM role
    policy = data.aws_iam_policy_document.ec2_policy.json  # Use the generated policy document as the policy
}

# ----------------------------------------------------------
# Create Trust, IAM, and Resource policy documents with data sources
# These data blocks can be used for modular or advanced setups
# ----------------------------------------------------------

# Trust policy document for EC2 service to assume the role
data "aws_iam_policy_document" "trust_policy" {
    statement {
        actions = ["sts:AssumeRole"]                # Allow EC2 to assume the role
        effect  = "Allow"                           # Allow the action
        principals {
            type        = "Service"                 # Principal type is AWS service
            identifiers = ["ec2.amazonaws.com"]     # EC2 service principal
        }
    }
}

# IAM policy document granting S3 list, get, and put permissions
data "aws_iam_policy_document" "iam_policy" {
    statement {
        actions = [
            "s3:ListBucket",                        # Allow listing S3 buckets
            "s3:GetObject"                          # Allow reading objects from S3
        ]
        effect   = "Allow"                          # Allow the actions
        resources = ["*"]                           # Applies to all S3 resources
    }

    statement {
        actions = [
            "s3:PutObject"                          # Allow uploading objects to S3
        ]
        effect   = "Allow"                          # Allow the action
        resources = ["*"]                           # Applies to all S3 resources
    }
}

# Resource policy document granting S3 permissions to EC2 service principal
data "aws_iam_policy_document" "resource_policy" {
    statement {
        actions = [
            "s3:ListBucket",                        # Allow listing S3 buckets
            "s3:GetObject",                         # Allow reading objects from S3
            "s3:PutObject"                          # Allow uploading objects to S3
        ]
        effect   = "Allow"                          # Allow the actions
        resources = ["*"]                           # Applies to all S3 resources
        principals {
            type        = "Service"                 # Principal type is AWS service
            identifiers = ["ec2.amazonaws.com"]     # EC2 service principal
        }
    }
}
# ----------------------------------------------------------
# Locals for policy documents
# ----------------------------------------------------------
locals {
    ec2_trust_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    ec2_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:ListBucket",
                    "s3:GetObject"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "s3:PutObject"
                ]
                Resource = "*"
            }
        ]
    })
}
# ----------------------------------------------------------
