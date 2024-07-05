#!/bin/bash

set -e

echo "Generating or retrieving credentials..."
source projects/nextcloud/secrets.env

read -sn1 -p "Delete namespace first? (y/N) " DELETE
if [ "$DELETE" == "y" ]; then
    helm delete -n nextcloud nextcloud --wait || true
    kubectl delete ns nextcloud --wait || true
    kubectl create ns nextcloud || true
fi

echo "Generating nextcloud passwords..."
if kubectl get secrets -n nextcloud | grep -q "nextcloud-admin"; then
    echo "Secret nextcloud-admin already exists"
else
    echo "Generating nextcloud-admin..."
    if [ -z "$NC_PASSWORD" ]; then
        NC_PASSWORD=$(openssl rand -base64 20)
    fi
    kubectl create secret -n nextcloud generic nextcloud-admin \
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
if kubectl get secrets -n nextcloud | grep -q mariadb-passwords; then
    echo "Secret mariadb-passwords already exists"
else
    echo "Generating mariadb-passwords..."
    MARIADB_PASSWORD=$(openssl rand -base64 20)
    MARIADB_ROOT_PASSWORD=$(openssl rand -base64 20)
    MARIADB_REPLICATION_PASSWORD=$(openssl rand -base64 20)
    MARIADB_USERNAME=nextcloud
    kubectl create secret -n nextcloud generic mariadb-passwords \
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

# echo "Creating data pvc..."
# if kubectl get pvc -n nextcloud | grep -q nextcloud-data; then
#     echo "PVC nextcloud-data already exists"
# else
#     echo "Creating nextcloud-data..."
#     kubectl apply -f projects/nextcloud/nextcloud-data.yaml -n nextcloud
# fi

# echo "Installing Nextcloud..."
# helm repo add nextcloud https://nextcloud.github.io/helm/
# helm repo update
# helm upgrade --install nextcloud nextcloud/nextcloud \
#     --namespace nextcloud \
#     --create-namespace \
#     --values projects/nextcloud/values.yaml \
#     --set nextcloud.host=$NC_HOST

