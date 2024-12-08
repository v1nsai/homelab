#!/bin/bash

set -e
source apps/services/devbox/.env

kubectl create secret generic ssh-pubkey \
    --namespace=devbox \
    --from-literal=username="$USERNAME" \
    --from-literal=authorized_keys="$AUTHORIZED_KEYS" \
    --dry-run=client -o yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > ./apps/services/devbox/app/sealed-secrets.yaml

# create configmap for the postinstal.sh script
kubectl create configmap postinstall \
    --namespace=devbox \
    --from-file=postinstall.sh=./apps/services/devbox/files/postinstall.sh \
    --dry-run=client -o yaml > ./apps/services/devbox/app/configmap.yaml