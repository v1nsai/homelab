#!/bin/bash

set -e
source projects/cloudflared/.env
# To create a new tunnel, follow official docs https://developers.cloudflare.com/cloudflare-one/tutorials/many-cfd-one-tunnel/#install-cloudflared

# Use an existing tunnel created in the UI, use cloudflare-tunnel-remote chart.  For local administration, use cloudflare-tunnel
helm repo add cloudflare https://cloudflare.github.io/helm-charts
helm repo update
helm upgrade --install cloudflared cloudflare/cloudflare-tunnel-remote \
    --namespace cloudflare \
    --create-namespace \
    --set cloudflare.tunnel_token=$CF_TUNNEL_TOKEN

# CLOUDFLARED_TUNNEL_JSON="projects/cloudflared/k8s/cloudflared.json.env"
# cat > $CLOUDFLARED_TUNNEL_JSON <<- EOM
# {
#     "AccountTag": "${CLOUDFLARED_ACCOUNT_TAG}",
#     "TunnelSecret": "${CLOUDFLARED_TUNNEL_SECRET}",
#     "TunnelID": "${CLOUDFLARED_TUNNEL_ID}"
# }
# EOM

# kubectl create namespace cloudflare
# kubectl create secret generic -n cloudflare tunnel-credentials \
#     --from-file=projects/cloudflared/k8s/cloudflared.json.env
