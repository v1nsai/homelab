#!/bin/bash

set -e

echo "Generating or retrieving credentials..."
source apps/services/nextcloud/secrets.env

if [ -z "$NC_HOST" ]; then
    read -sn1 -p "Enter Nextcloud host: " NC_HOST
    cat "NC_HOST=$NC_HOST" >> apps/services/nextcloud/secrets.env
    export NC_HOST="$NC_HOST"
fi

echo "Generating nextcloud passwords..."
echo "Generating nextcloud-admin..."
if [ -z "$NC_PASSWORD" ]; then
    NC_PASSWORD=$(openssl rand -base64 20)
fi
kubectl create secret -n nextcloud generic nextcloud-admin \
    --from-literal=nextcloud-password=$NC_PASSWORD \
    --from-literal=nextcloud-host=$NC_HOST \
    --from-literal=nextcloud-username=admin \
    --from-literal=nextcloud-token=$NC_PASSWORD \
    --dry-run=client \
    --output=yaml > apps/services/nextcloud/secret.yaml
kubeseal --format=yaml --cert=./.sealed-secrets.pub < apps/services/nextcloud/secret.yaml | tee -a apps/services/nextcloud/app/sealed-secrets.yaml

echo "Generating mariadb passwords..."
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
    --from-literal=mariadb-username=$MARIADB_USERNAME \
    --dry-run=client \
    --output=yaml > apps/services/nextcloud/secret.yaml
kubeseal --format=yaml --cert=./.sealed-secrets.pub < apps/services/nextcloud/secret.yaml | tee -a apps/services/nextcloud/app/sealed-secrets.yaml

echo "Generating redis credentials..."
echo "Generating redis-password..."
REDIS_PASSWORD=$(openssl rand -base64 20)
kubectl create secret -n nextcloud generic redis-password \
    --from-literal=redis-password=$REDIS_PASSWORD \
    --dry-run=client \
    --output=yaml > apps/services/nextcloud/secret.yaml
kubeseal --format=yaml --cert=./.sealed-secrets.pub < apps/services/nextcloud/secret.yaml | tee -a apps/services/nextcloud/app/sealed-secrets.yaml

echo "Creating self signed certs..."
echo "Generating selfsigned-tls..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/nextcloud.key -out /tmp/nextcloud.crt \
    -subj "/CN=$NC_HOST"
kubectl create secret -n nextcloud tls selfsigned-tls \
    --cert=/tmp/nextcloud.crt \
    --key=/tmp/nextcloud.key \
    --dry-run=client \
    --output=yaml > apps/services/nextcloud/secret.yaml
kubeseal --format=yaml --cert=./.sealed-secrets.pub < apps/services/nextcloud/secret.yaml | tee -a apps/services/nextcloud/app/sealed-secrets.yaml

echo "Configuring secret values..."
cat << EOF > /tmp/secret-values.yaml
nextcloud:
  host: $NC_HOST
EOF
kubectl create secret generic -n nextcloud secret-values \
    --from-file=/tmp/secret-values.yaml \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml | tee -a apps/services/nextcloud/app/sealed-secrets.yaml

rm -rf /tmp/nextcloud.key /tmp/nextcloud.crt /tmp/secret-values.yaml
rm -rf apps/services/nextcloud/secret.yaml