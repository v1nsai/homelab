#!/bin/bash

set -e
source apps/services/devbox/.env

kubectl create secret generic ssh-pubkey \
    --from-literal=authorized_keys="$SSH_PUBKEY" \
    --dry-run=client -o yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > ./apps/services/devbox/app/sealed-secrets.yaml