echo "export AWS_ACCESS_KEY_ID=$(terraform output -raw access_key)" > ../../.aws_creds/pseu.sh
echo "export AWS_SECRET_ACCESS_KEY=$(terraform output -raw secret_key)" >> ../../.aws_creds/pseu.sh