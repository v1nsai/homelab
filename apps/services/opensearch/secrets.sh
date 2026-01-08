#!/bin/bash

set -e
source apps/services/opensearch/.env

echo "Configuring secret values..."
cat << EOF > /tmp/data
username: "$USERNAME"
password: "$PASSWORD"
EOF
kubectl create secret generic -n opensearch opensearch-auth \
    --from-file=/tmp/data \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml | tee -a apps/services/opensearch/opensearch/opensearch-auth-sealed.yaml

rm -rf /tmp/data