#!/bin/bash

set -e
source projects/airflow/secrets.env

if [ -z "$USER_EMAIL" ] || [ -z "$USER_NAME" ] || [ -z "$USER_FIRSTNAME" ] || [ -z "$USER_LASTNAME" ]; then
    echo "Please set USER_EMAIL, USER_NAME, USER_FIRSTNAME and USER_LASTNAME in projects/airflow/secrets.env"
    exit 1
fi

echo "Creating and encrypting secrets..."
USER_PASSWORD=$(openssl rand -base64 20)
AIRFLOW__CORE__FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")
WEB_SERVER_SECRET_KEY=$(openssl rand -base64 20)
kubectl create secret generic airflow-auth \
    --from-literal=auth-username="$USER_NAME" \
    --from-literal=auth-password="$USER_PASSWORD" \
    --from-literal=auth-email="$USER_EMAIL" \
    --from-literal=auth-firstname="$USER_FIRSTNAME" \
    --from-literal=auth-lastname="$USER_LASTNAME" \
    --from-literal=fernet-key="$AIRFLOW__CORE__FERNET_KEY" \
    --from-literal=webserver-secret-key="$WEB_SERVER_SECRET_KEY" \
    --namespace airflow \
    --dry-run=client \
    --output=yaml > projects/airflow/airflow-auth.yaml
kubeseal --format=yaml --cert=./.sealed-secrets.pub < projects/airflow/airflow-auth.yaml | tee -a projects/airflow/app/sealed-secrets.yaml
rm projects/airflow/airflow-auth.yaml

cat > projects/airflow/secret-values.yaml <<-EOF
webserver:
  defaultUser:
    username: $USER_NAME
    password: $USER_PASSWORD
    email: $USER_EMAIL
    firstname: $USER_FIRSTNAME
    lastname: $USER_LASTNAME
EOF
kubectl create secret generic secret-values \
    --from-file=projects/airflow/secret-values.yaml \
    --namespace airflow \
    --dry-run=client \
    --output=yaml > projects/airflow/secret-values-secret.yaml
kubeseal --format=yaml --cert=./.sealed-secrets.pub < projects/airflow/secret-values-secret.yaml | tee -a projects/airflow/app/sealed-secret-values.yaml
rm projects/airflow/secret-values-secret.yaml projects/airflow/secret-values.yaml
