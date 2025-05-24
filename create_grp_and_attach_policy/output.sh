# export AWS User access key
echo "export AWS_ACCESS_KEY_ID=$(terraform output -raw devops_user_access_key)" > ../../.aws_creds/devops_user_creds.sh
# export AWS User secret key
echo "export AWS_SECRET_ACCESS_KEY=$(terraform output -raw devops_user_secret_key)" >> ../../.aws_creds/devops_user_creds.sh