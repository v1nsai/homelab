#!/bin/bash

set -e

# TODO put back once https://github.com/minio/operator/pull/2284 is merged
# kubectl create secret generic user-keys \
#     --namespace minio-tenant \
#     --from-literal accessKey="$(openssl rand -base64 32)" \
#     --from-literal secretKey="$(openssl rand -base64 32)" \
#     --dry-run=client \
#     --output yaml | \
# kubeseal --cert ./.sealed-secrets.pub --format yaml > ./cluster/addons/minio/tenant/sealed-secrets.yaml

cat <<EOF > /tmp/secret-values.yaml
secrets:
  name: homelab-minio-env-configuration
  accessKey: $(openssl rand -base64 32)
  secretKey: $(openssl rand -base64 32)
EOF
kubectl create secret generic secret-values \
    --from-file=/tmp/secret-values.yaml \
    --namespace minio-tenant \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > ./cluster/addons/minio/tenant/sealed-secrets.yaml