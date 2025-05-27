# Configure Terrafrom to use the AWS provider
terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.95"
        }
    }
}

#Configure the AWS provider for the Hyderabad region
provider "aws" {
  region = "ap-south-2"
}

# Use Terraform local for cleaner policies
# This local value defines an S3 read-only bucket policy.
# Note:
# - The "Principal" field is typically used when creating resource-based policies (such as S3 bucket policies or SNS topic policies).
# - For IAM identity-based policies (attached to users, groups, or roles), you should NOT specify the "Principal" field.
# - In resource-based policies (like this S3 bucket policy), the "Principal" field is required to specify who is allowed or denied access.
# - In identity-based policies, AWS automatically infers the principal from the identity the policy is attached to.
# - If you add a user's ARN to the "Principal" field in a resource-based policy, that user can access the resource even if no identity-based policy is attached to the user (as long as they have valid credentials).
# - You do NOT need to add policies on both sides. Use either a resource-based policy or an identity-based policy depending on your use case. Sometimes both are used for extra control, but it is not required by default.
locals {
    s3_readonly_bucket_policy = {
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = "arn:aws:s3:::my-readonly-bucket-${random_string.bucket_suffix.result}/*"
            },
            {
                Effect = "Allow"
                Principal = "*"
                Action = "s3:ListBucket"
                Resource = "arn:aws:s3:::my-readonly-bucket-${random_string.bucket_suffix.result}"
            },
            {
                Effect = "Deny"
                Principal = "*"
                Action = "s3:DeleteObject"
                # Specifies the ARN of the S3 bucket and all its objects as the resource for the policy statement.
                # The bucket name is dynamically generated using a random string suffix for uniqueness.
                # 
                # You can further customize this input by:
                # - Changing the bucket name prefix ("my-readonly-bucket-") to match your naming conventions.
                # - Modifying the resource path to target specific folders or objects within the bucket.
                # - Using variables or data sources to reference existing bucket names or suffixes.
                # - Adjusting the resource pattern to include or exclude certain objects as needed.
                Resource = "arn:aws:s3:::my-readonly-bucket-${random_string.bucket_suffix.result}/*"
                # Other possible values for the "Resource" field:
                # - "*" : Applies to all resources in AWS (not recommended for production).
                # - "arn:aws:s3:::my-readonly-bucket-${random_string.bucket_suffix.result}" : Applies only to the bucket itself (not objects).
                # - "arn:aws:s3:::my-readonly-bucket-${random_string.bucket_suffix.result}/folder/*" : Applies to all objects within a specific folder.
                # - "arn:aws:s3:::my-readonly-bucket-*" : Applies to all buckets with the specified prefix (use with caution).
                # - Use a list for multiple resources:
                #   Resource = [
                #     "arn:aws:s3:::my-readonly-bucket-${random_string.bucket_suffix.result}/*",
                #     "arn:aws:s3:::another-bucket/*"
                #   ]
            }
        ]
    }
}

# Use Terraform data block to define the S3 read-only bucket policy as a template.
# This approach allows you to manage the policy as a separate file or inline template.
# The templatefile function can be used to render the policy with variables if needed.
# Here, we use a data "aws_iam_policy_document" to generate the policy JSON.

# data "aws_iam_policy_document" "s3_readonly_bucket_policy" {
#     statement {
#         effect = "Allow"
#         principals {
#             type        = "*"
#             identifiers = ["*"]
#         }
#         actions   = ["s3:GetObject"]
#         resources = ["*"]
#     }

#     statement {
#         effect = "Allow"
#         principals {
#             type        = "*"
#             identifiers = ["*"]
#         }
#         actions   = ["s3:ListBucket"]
#         resources = ["*"]
#     }

#     statement {
#         effect = "Deny"
#         principals {
#             type        = "*"
#             identifiers = ["*"]
#         }
#         actions   = ["s3:DeleteObject"]
#         resources = ["*"]
#     }
# }

# create a random string to ensure unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  
}

# Create an S3 bucket with a read-only policy
resource "aws_s3_bucket" "readonly_bucket" {
  bucket = "my-readonly-bucket-${random_string.bucket_suffix.result}"
  depends_on = [ random_string.bucket_suffix ]
}

# Block Public Access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "readonly_bucket_block" {
  bucket = aws_s3_bucket.readonly_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Attach the read-only policy to the S3 bucket
resource "aws_s3_bucket_policy" "readonly_policy" {
  bucket = aws_s3_bucket.readonly_bucket.id
  policy = jsonencode(local.s3_readonly_bucket_policy)
}