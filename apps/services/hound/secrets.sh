#!/bin/bash

POSTGRES_PASSWORD=$(openssl rand -base64 32)
HOUND_SECRET=$(openssl rand -base64 32)

kubectl create secret generic hound-server-secret \
    --from-literal=postgres_password="$POSTGRES_PASSWORD" \
    --from-literal=hound_secret="$HOUND_SECRET" \
    --namespace hound \
    --dry-run=client \
    --output yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub >> apps/services/hound/app/sealed-secrets.yaml
