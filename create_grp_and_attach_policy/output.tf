# Output the IAM user access key
output "devops_user_access_key" {
  value = aws_iam_access_key.devops_user_access_key.id
}

# Output the IAM user secret key
output "devops_user_secret_key" {
  value     = aws_iam_access_key.devops_user_access_key.secret
  sensitive = true
}