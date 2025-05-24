# output access key
output "access_key" {
  value = aws_iam_access_key.pseu_access_key.id
}

# output secret key
output "secret_key" {
  value     = aws_iam_access_key.pseu_access_key.secret
  sensitive = true
}
