# -----------------------------------------------------------
# Terraform Block: Specifies the required provider and version
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"   # AWS provider source from HashiCorp registry
            version = "~> 5.95.0"       # Use AWS provider version 5.95.0 or compatible minor versions
        }
    }
}

# -----------------------------------------------------------
# Provider Block: Configures the AWS provider
provider "aws" {
    region = "ap-south-2"           # Set AWS region to Hyderabad (ap-south-2)
}

# -----------------------------------------------------------
# Data Block: IAM Trust Policy for EC2
# This policy allows EC2 instances to assume the IAM role.
data "aws_iam_policy_document" "s3_access_role_trust_policy" {
    statement {
        actions = ["sts:AssumeRole"]  # Allow the sts:AssumeRole action
        principals {
            type        = "Service"     # Principal type is AWS service
            identifiers = ["ec2.amazonaws.com"] # Allow EC2 service to assume the role
        }
    }
}

# -----------------------------------------------------------
# Resource Block: IAM Role for EC2 S3 Access
# This role can be assumed by EC2 instances to access S3.
resource "aws_iam_role" "s3_access_role" {
    name               = "AccessS3FromEC2Role" # Name of the IAM role
    assume_role_policy = data.aws_iam_policy_document.s3_access_role_trust_policy.json # Attach trust policy
}

# -----------------------------------------------------------
# Resource Block: IAM Instance Profile
# Instance profiles are required to attach IAM roles to EC2 instances.
# The 'name' attribute explicitly sets the name of the instance profile.
# - Specifying a name is optional; if omitted, Terraform will auto-generate one.
# - Providing a name makes it easier to reference and identify the profile in the AWS Console or CLI.
# - It is not strictly required, but recommended for clarity, consistency, and easier management.
# - The instance profile acts as a container for the IAM role, enabling EC2 to use the role's permissions.
resource "aws_iam_instance_profile" "s3_access_instance_profile" {
    name = "AccessS3FromEC2InstanceProfile"    # (Optional) Name for easier identification and management
    role = aws_iam_role.s3_access_role.name    # Attach the IAM role created above
}
# -----------------------------------------------------------
# Resource Block: Attach S3 Full Access Policy to IAM Role
# Grants the IAM role full access to S3 resources.
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
    role       = aws_iam_role.s3_access_role.name           # Attach to the IAM role
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # AWS managed policy for S3 full access
}

# -----------------------------------------------------------
# Resource Block: EC2 Instance with IAM Role
# Launches an EC2 instance with the IAM instance profile attached.
resource "aws_instance" "ec2_with_s3_access" {
    ami                  = "ami-053a0835435bf4f45"          # AMI ID for the EC2 instance
    instance_type        = "t3.micro"                       # Instance type
    iam_instance_profile = aws_iam_instance_profile.s3_access_instance_profile.name # Attach instance profile

    tags = {
        Name = "EC2InstanceWithS3Access"                      # Tag for easy identification
    }

    depends_on = [
        aws_iam_role.s3_access_role,                          # Ensure IAM role is created first
        aws_iam_instance_profile.s3_access_instance_profile,  # Ensure instance profile is created
        aws_iam_role_policy_attachment.s3_access_policy_attachment # Ensure policy is attached
    ]
}
# -----------------------------------------------------------
