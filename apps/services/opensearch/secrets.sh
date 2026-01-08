#!/bin/bash

set -e
source apps/services/opensearch/.env

echo "Configuring secret values..."
kubectl create secret generic -n opensearch opensearch-auth \
    --from-literal=username="$USERNAME" \
    --from-literal=password="$PASSWORD" \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > apps/services/opensearch/opensearch/opensearch-auth-sealed.yaml

rm -rf /tmp/data