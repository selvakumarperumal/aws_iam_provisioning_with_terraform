# export AWS_ACCESS_KEY_ID=
echo "export AWS_ACCESS_KEY_ID=$(terraform output -raw dev_user_access_key_id)" > ../../.aws_creds/dev_user_creds.sh
# export AWS_SECRET_ACCESS_KEY=
echo "export AWS_SECRET_ACCESS_KEY=$(terraform output -raw dev_user_secret_access_key)" >> ../../.aws_creds/dev_user_creds.sh