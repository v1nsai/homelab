#!/bin/bash

set -e
source apps/services/opensearch/.env

echo "Configuring secret values..."
kubectl create secret generic -n opensearch opensearch-auth \
    --from-literal=OPENSEARCH_INITIAL_ADMIN_PASSWORD="$PASSWORD" \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > apps/services/opensearch/opensearch/opensearch-auth-sealed.yaml

rm -rf /tmp/data

# Update service name after installation because its the exact same in opensearch charts for some reason
kubectl -n opensearch patch svc opensearch-cluster-master --type='json' -p='[
    {
        "op": "replace",
        "path": "/metadata/name",
        "value": "opensearch"
    }
]'