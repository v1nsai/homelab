#!/bin/bash

set -e
source projects/airflow/secrets.env

# helm repo add airflow-stable https://airflow-helm.github.io/charts
# helm repo add apache-airflow https://airflow.apache.org
# helm repo update

echo "Configuring users, auth and encryption..."
if ! kubectl get secret airflow-auth -n airflow &> /dev/null; then
    echo "Creating secret airflow-auth..."
    USER_PASSWORD=$(openssl rand -base64 20)
    AIRFLOW__CORE__FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")
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

echo "Building airflow image..."
echo "Rebasing airflow image on python:3.8-slim-bullseye..."
git clone git@github.com:apache/airflow.git projects/airflow/airflow || true
docker build -t apache/airflow:custom-bullseye projects/airflow/airflow --build-arg PYTHON_BASE_IMAGE=python:3.8-slim-bullseye
echo "Building airflow image with nvidia support..."
docker build -t apache/airflow:custom-nvidia projects/airflow

echo "Installing Airflow..."
# helm upgrade --install airflow airflow-stable/airflow \
#     --namespace airflow \
#     --create-namespace 
#     # --values projects/airflow/values.yaml

#     # --set airflow.config.AIRFLOW__CORE__FERNET_KEY="${AIRFLOW__CORE__FERNET_KEY}" \

helm delete -n airflow airflow || true
kubectl delete all --all -n airflow || true
kubectl delete pvc --all -n airflow || true
sleep 30
helm upgrade --install airflow apache-airflow/airflow \
    --namespace airflow \
    --create-namespace \
    --set images.airflow.repository="apache/airflow" \
    --set images.airflow.tag="custom-nvidia" \
    --set webserver.defaultUser.username="${USER_NAME}" \
    --set webserver.defaultUser.password="${USER_PASSWORD}" \
    --set webserver.defaultUser.email="${USER_EMAIL}" \
    --set webserver.defaultUser.firstName="${USER_FIRSTNAME}" \
    --set webserver.defaultUser.lastName="${USER_LASTNAME}" \
    --set webserver.service.type=LoadBalancer \
    --set webserverSecretKeyName=airflow-auth \
    --set workers.waitForMigrations.enabled=true \
    --set config.core.load_examples="True" \
    --values projects/airflow/apache-airflow-values.yaml