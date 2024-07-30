#!/bin/bash

set -e
source projects/cloudflare/.env

# Create a secret for the tunnel token
cat << EOF > /tmp/secret-values.yaml
cloudflare:
  tunnel_token: $CF_TUNNEL_TOKEN
EOF
kubectl create secret generic -n cloudflare secret-values \
    --from-file=/tmp/secret-values.yaml \
    --dry-run=client \
    --output yaml | \
    kubeseal --cert ./.sealed-secrets.pub --format yaml > projects/cloudflare/app/sealed-secret-values.yaml

