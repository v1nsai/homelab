#!/bin/bash

set -e

# REMOVE FOR TESTING ONLY
helm -n nextcloud uninstall nextcloud || true

echo "Generating or retrieving credentials..."
source projects/nextcloud/secrets.env
NC_ADMIN_SECRET_NAME=nextcloud-admin
NC_NAMESPACE=nextcloud
MARIADB_SECRET_NAME=mariadb-passwords
STORAGECLASS=ceph-rbd

if kubectl get secrets -n nextcloud | grep -q "$NC_ADMIN_SECRET_NAME"; then
    echo "Secret $NC_ADMIN_SECRET_NAME already exists"
else
    echo "Generating $NC_ADMIN_SECRET_NAME..."
    NC_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret -n nextcloud generic $NC_ADMIN_SECRET_NAME \
        --from-literal=nextcloud-password=$NC_PASSWORD \
        --from-literal=nextcloud-host=$NC_HOST \
        --from-literal=nextcloud-username=admin \
        --from-literal=nextcloud-token=$NC_PASSWORD \
        --from-literal=smtp-password=$SMTP_PASS \
        --from-literal=smtp-host=$SMTP_HOST \
        --from-literal=smtp-port=$SMTP_PORT \
        --from-literal=smtp-username=$SMTP_USER
fi

if kubectl get secrets -n nextcloud | grep -q $MARIADB_SECRET_NAME; then
    echo "Secret mariadb-passwords already exists"
else
    echo "Generating mariadb-passwords..."
    MARIADB_PASSWORD=$(openssl rand -base64 20)
    MARIADB_ROOT_PASSWORD=$(openssl rand -base64 20)
    MARIADB_REPLICATION_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret -n nextcloud generic mariadb-passwords \
        --from-literal=mariadb-password=$MARIADB_PASSWORD \
        --from-literal=password=$MARIADB_PASSWORD \
        --from-literal=mariadb-root-password=$MARIADB_ROOT_PASSWORD \
        --from-literal=mariadb-replication-password=$MARIADB_REPLICATION_PASSWORD
fi

helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm install nextcloud nextcloud/nextcloud \
    --namespace nextcloud \
    --set ingress.enabled=false \
    --set nextcloud.host=$NC_HOST \
    --set nextcloud.username=admin \
    --set nextcloud.existingSecret.enabled=true \
    --set nextcloud.existingSecret.secretName=$NC_ADMIN_SECRET_NAME \
    --set externalDatabase.enabled=true \
    --set mariadb.enabled=true \
    --set mariadb.auth.existingSecret=$MARIADB_SECRET_NAME \
    --set persistence.enabled=true \
    --set persistence.storageClass=$STORAGECLASS 
    # --set mariadb.primary.persistence.enabled=true \
    # --set mariadb.primary.persistence.storageClass=$STORAGECLASS \
    # --set persistence.nextcloudData.enabled=true \
    # --set persistence.nextcloudData.storageClass=$STORAGECLASS 

kubectl get events -n nextcloud -w