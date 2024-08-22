#!/bin/bash

set -e

kubectl create secret generic harbor-admin-password \
    --namespace harbor \
    --from-literal=HARBOR_ADMIN_PASSWORD="$(openssl rand -base64 32)" \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > ./apps/services/harbor/app/sealed-secrets.yaml