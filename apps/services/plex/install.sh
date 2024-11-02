#!/bin/bash

set -e
# source projects/plex/.env

echo "Please enter your Plex Claim token:"
read -r PLEX_CLAIM

cat <<EOF > /tmp/secret-values.yaml
extraEnv:
  PLEX_CLAIM: $PLEX_CLAIM
EOF
kubectl create secret generic secret-values \
    --from-file=/tmp/secret-values.yaml \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > ./apps/services/plex/app/sealed-secrets.yaml