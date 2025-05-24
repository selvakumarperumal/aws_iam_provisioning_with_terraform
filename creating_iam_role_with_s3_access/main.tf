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
  region = "ap-south-2"
}

# create iam user
resource "aws_iam_user" "example" {
  name = "pseu"
}

# attach policy to user
# add s3 read only policy to user
resource "aws_iam_user_policy_attachment" "example" {
  user       = aws_iam_user.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# create access key for user
resource "aws_iam_access_key" "pseu_access_key" {
  user = aws_iam_user.example.name
}