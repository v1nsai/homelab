#!/bin/bash

set -e
source ./cluster/addons/minio/secrets.env

if [ -z "$MINIO_ROOT_USER" ] || [ -z "$MINIO_ROOT_PASSWORD" ]; then
    echo "MINIO_ROOT_USER or MINIO_ROOT_PASSWORD is not set. Exiting."
    exit 1
fi

# Secret values
cat <<EOF > /tmp/secret-values.yaml
secrets:
  name: homelab-minio-env-configuration
  accessKey: $(openssl rand -base64 32)
  secretKey: $(openssl rand -base64 32)
EOF
kubectl create secret generic secret-values \
  --from-file=values.yaml=/tmp/secret-values.yaml \
  --namespace minio-tenant \
  --dry-run=client \
  --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > ./cluster/addons/minio/tenant/sealed-secrets.yaml

# Minio config
source ./cluster/addons/minio/secrets.env
cat <<EOF > /tmp/config.env
export MINIO_ROOT_USER="$MINIO_ROOT_USER"
export MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD"
EOF
kubectl create secret generic homelab-env \
  --from-file=config.env=/tmp/config.env \
  --namespace minio-tenant \
  --dry-run=client \
  --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml | tee -a ./cluster/addons/minio/tenant/sealed-secrets.yaml