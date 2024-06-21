#!/bin/bash

set -e
source projects/airflow/secrets.env

if [ -z "$USER_EMAIL" ] || [ -z "$USER_NAME" ] || [ -z "$USER_FIRSTNAME" ] || [ -z "$USER_LASTNAME" ]; then
    echo "Please set USER_EMAIL, USER_NAME, USER_FIRSTNAME and USER_LASTNAME in projects/airflow/secrets.env"
    exit 1
fi

read -sn1 -p "Delete existing airflow namespace first? [y/N]" DELETE
if [ "$DELETE" == "y" ]; then
    helm delete -n airflow airflow || true
    kubectl delete namespace airflow || true
    kubectl create namespace airflow || true
fi

echo "Configuring users, auth and encryption..."
if ! kubectl get secret airflow-auth -n airflow &> /dev/null; then
    echo "Creating secret airflow-auth..."
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
        --namespace airflow
else
    echo "Secret airflow-auth already exists."
    AIRFLOW__CORE__FERNET_KEY="$(kubectl get secret airflow-auth -n airflow -o jsonpath='{.data.fernet-key}' | base64 -d)"
    USER_PASSWORD="$(kubectl get secret airflow-auth -n airflow -o jsonpath='{.data.auth-password}' | base64 -d)"
fi

echo "Installing Airflow..."
# helm repo add apache-airflow https://airflow.apache.org
# helm repo update
helm upgrade --install airflow apache-airflow/airflow \
    --namespace airflow \
    --create-namespace \
    --values projects/airflow/values.yaml \
    --set webserver.defaultUser.username="${USER_NAME}" \
    --set webserver.defaultUser.password="${USER_PASSWORD}" \
    --set webserver.defaultUser.email="${USER_EMAIL}" \
    --set webserver.defaultUser.firstName="${USER_FIRSTNAME}" \
    --set webserver.defaultUser.lastName="${USER_LASTNAME}"