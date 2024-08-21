#!/bin/bash

set -e

kubectl create secret generic user-keys \
    --namespace minio-tenant \
    --from-literal accessKey="$(openssl rand -base64 32)" \
    --from-literal secretKey="$(openssl rand -base64 32)" \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > ./cluster/addons/minio/tenant/sealed-secrets.yaml