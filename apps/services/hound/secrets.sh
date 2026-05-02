#!/bin/bash

# generate secrets without "=" at the end of the value which breaks the postgres connection string
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d '=')
HOUND_SECRET=$(openssl rand -base64 32 | tr -d '=')

kubectl create secret generic hound-server-secret \
    --from-literal=postgres_password="$POSTGRES_PASSWORD" \
    --from-literal=hound_secret="$HOUND_SECRET" \
    --namespace hound \
    --dry-run=client \
    --output yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > apps/services/hound/app/sealed-secrets.yaml
