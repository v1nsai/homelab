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

# Use an existing tunnel created in the UI, use cloudflare-tunnel-remote chart.  For local administration, use cloudflare-tunnel
helm repo add cloudflare https://cloudflare.github.io/helm-charts
helm repo update
helm upgrade --install cloudflared cloudflare/cloudflare-tunnel-remote \
    --namespace cloudflare \
    --create-namespace \
    --set cloudflare.tunnel_token=$CF_TUNNEL_TOKEN

flux create source helm cloudflare \
    --interval=1h \
    --url=https://cloudflare.github.io/helm-charts \
    --export > projects/cloudflare/app/helmrepository.yaml

flux create helmrelease cloudflared \
    --interval=1h \
    --source=HelmRepository/cloudflare \
    --chart=cloudflare-tunnel-remote \
    --target-namespace=cloudflare \
    --export > projects/cloudflared/app/helmrelease.yaml

flux create kustomization cloudflared \
    --interval=1h \
    --source=GitRepository/homelab \
    --path="./projects/cloudflared/app" \
    --prune=true \
    --export > projects/cloudflared/app/kustomization.yaml
