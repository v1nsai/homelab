#!/bin/bash

set -e

# REMOVE FOR TESTING ONLY
# helm uninstall nextcloud || true

echo "Generating or retrieving credentials..."
NC_ADMIN_SECRET_NAME=nextcloud-admin
NC_NAMESPACE=nextcloud
MARIADB_SECRET_NAME=mariadb-passwords

if kubectl get secrets -n nextcloud | grep -q "$NC_ADMIN_SECRET_NAME"; then
    echo "Secret $NC_ADMIN_SECRET_NAME already exists"
else
    echo "Generating $NC_ADMIN_SECRET_NAME..."
    source projects/nextcloud/secrets.env
    NC_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret generic $NC_ADMIN_SECRET_NAME \
        --from-literal=nextcloud-password=$NC_PASSWORD \
        --from-literal=nextcloud-host=$NC_HOST \
        --from-literal=nextcloud-username=admin \
        --from-literal=SMTP_PASS=$SMTP_PASS \
        --from-literal=SMTP_HOST=$SMTP_HOST \
        --from-literal=SMTP_PORT=$SMTP_PORT \
        --from-literal=SMTP_USER=$SMTP_USER
fi

if kubectl get secrets | grep -q $MARIADB_SECRET_NAME; then
    echo "Secret mariadb-passwords already exists"
else
    echo "Generating mariadb-passwords..."
    MARIADB_PASSWORD=$(openssl rand -base64 20)
    MARIADB_ROOT_PASSWORD=$(openssl rand -base64 20)
    MARIADB_REPLICATION_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret generic mariadb-passwords \
        --from-literal=mariadb-password=$MARIADB_PASSWORD \
        --from-literal=mariadb-root-password=$MARIADB_ROOT_PASSWORD \
        --from-literal=mariadb-replication-password=$MARIADB_REPLICATION_PASSWORD
fi

# echo "Installing the repo and helm chart..."
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update

# helm install -f projects/nextcloud/values.yaml nextcloud nextcloud/nextcloud

# kubectl get secret --namespace default nextcloud -o jsonpath="{.data.nextcloud-password}" | base64 --decode
