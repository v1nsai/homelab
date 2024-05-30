#!/bin/bash

set -e

echo "Generating or retrieving credentials..."
source projects/nextcloud/secrets.env
NC_ADMIN_SECRET_NAME=nextcloud-admin
NC_NAMESPACE=nextcloud
MARIADB_SECRET_NAME=mariadb-passwords
STORAGECLASS=nfs-client

echo "Generating nextcloud passwords..."
if kubectl get secrets -n nextcloud | grep -q "$NC_ADMIN_SECRET_NAME"; then
    echo "Secret $NC_ADMIN_SECRET_NAME already exists"
else
    echo "Generating $NC_ADMIN_SECRET_NAME..."
    if [ -z "$NC_PASSWORD" ]; then
        NC_PASSWORD=$(openssl rand -base64 20)
    fi
    kubectl create secret -n $NC_NAMESPACE generic $NC_ADMIN_SECRET_NAME \
        --from-literal=nextcloud-password=$NC_PASSWORD \
        --from-literal=nextcloud-host=$NC_HOST \
        --from-literal=nextcloud-username=admin \
        --from-literal=nextcloud-token=$NC_PASSWORD \
        --from-literal=smtp-password=$SMTP_PASS \
        --from-literal=smtp-host=$SMTP_HOST \
        --from-literal=smtp-port=$SMTP_PORT \
        --from-literal=smtp-username=$SMTP_USER
fi

echo "Generating mariadb passwords..."
if kubectl get secrets -n nextcloud | grep -q $MARIADB_SECRET_NAME; then
    echo "Secret mariadb-passwords already exists"
else
    echo "Generating mariadb-passwords..."
    MARIADB_PASSWORD=$(openssl rand -base64 20)
    MARIADB_ROOT_PASSWORD=$(openssl rand -base64 20)
    MARIADB_REPLICATION_PASSWORD=$(openssl rand -base64 20)
    MARIADB_USERNAME=nextcloud
    kubectl create secret -n nextcloud generic $MARIADB_SECRET_NAME \
        --from-literal=mariadb-password=$MARIADB_PASSWORD \
        --from-literal=password=$MARIADB_PASSWORD \
        --from-literal=mariadb-root-password=$MARIADB_ROOT_PASSWORD \
        --from-literal=mariadb-replication-password=$MARIADB_REPLICATION_PASSWORD \
        --from-literal=mariadb-username=$MARIADB_USERNAME
fi

echo "Generating redis credentials..."
if kubectl get secrets -n nextcloud | grep -q redis-password; then
    echo "Secret redis-password already exists"
else
    echo "Generating redis-password..."
    REDIS_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret -n nextcloud generic redis-password \
        --from-literal=redis-password=$REDIS_PASSWORD
fi

echo "Creating self signed certs..."
if kubectl get secrets -n nextcloud | grep -q selfsigned-tls; then
    echo "Secret selfsigned-tls already exists"
else
    echo "Generating selfsigned-tls..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /tmp/nextcloud.key -out /tmp/nextcloud.crt \
        -subj "/CN=$NC_HOST"
    kubectl create secret -n nextcloud tls selfsigned-tls \
        --cert=/tmp/nextcloud.crt \
        --key=/tmp/nextcloud.key
fi
rm -rf /tmp/nextcloud.key /tmp/nextcloud.crt

echo "Creating data pvc..."
if kubectl get pvc -n nextcloud | grep -q nextcloud-pvc; then
    echo "PVC nextcloud-pvc already exists"
else
    echo "Creating nextcloud-pvc..."
    kubectl apply -f projects/nextcloud/nextcloud-pvc.yaml
fi

echo "Installing Nextcloud..."
read -p "Delete first? (y/N)" DELETE
if [ "$DELETE" == "y" ]; then
    helm -n nextcloud uninstall nextcloud
    sleep 5
fi
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm upgrade --install nextcloud nextcloud/nextcloud \
    --namespace nextcloud \
    --create-namespace \
    --set nextcloud.host=$NC_HOST \
    --set nextcloud.existingSecret.secretName=$NC_ADMIN_SECRET_NAME \
    --set persistence.enabled=false \
    --set persistence.existingClaim=nextcloud-pvc \
    --set internalDatabase.enabled=false \
    --set externalDatabase.enabled=true \
    --set externalDatabase.existingSecret.enabled=true \
    --set externalDatabase.existingSecret.secretName=$MARIADB_SECRET_NAME \
    --set externalDatabase.existingSecret.usernameKey=mariadb-username \
    --set externalDatabase.existingSecret.passwordKey=mariadb-password \
    --set mariadb.enabled=true \
    --set mariadb.auth.existingSecret=$MARIADB_SECRET_NAME \
    --set mariadb.primary.persistence.enabled=true \
    --set cronjob.enabled=true \
    --set redis.enabled=true \
    --set redis.auth.existingSecret=redis-password \
    --set redis.auth.existingSecretKey=redis-password \
    --set redis.auth.enabled=false \
    --set service.type=LoadBalancer \
    --values projects/nextcloud/values.yaml

    # --set image.pullPolicy=Always \
    # --set nextcloud.mail.enabled=true \
    # --set nextcloud.mail.fromAddress=$SMTP_FROM \
    # --set nextcloud.mail.domain=$SMTP_DOMAIN \
    # --set nextcloud.mail.smtp.host=$SMTP_HOST \
    # --set nextcloud.mail.smtp.port=$SMTP_PORT \
    # --set nextcloud.mail.smtp.authtype=LOGIN \
    # --set nextcloud.mail.smtp.name=$SMTP_USER \
    # --set nextcloud.mail.smtp.password=$SMTP_PASS \