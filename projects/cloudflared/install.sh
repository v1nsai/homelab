#!/bin/bash

set -e
source projects/cloudflared/.env
# To create a new tunnel, follow official docs https://developers.cloudflare.com/cloudflare-one/tutorials/many-cfd-one-tunnel/#install-cloudflared

# Use an existing tunnel created in the UI
# get this info by going to existing tunnel in UI, going to configure, selecting Docker and copying the token after --token
# then go to jwt.io and paste the token in the debugger
# a = AccountTag, t = TunnelID, s = TunnelSecret
helm repo add cloudflare https://cloudflare.github.io/helm-charts
helm repo update
helm upgrade --install cloudflared cloudflare/cloudflare-tunnel \
    --namespace cloudflare \
    --create-namespace \
    --set cloudflare.account=$CLOUDFLARED_ACCOUNT_TAG \
    --set cloudflare.tunnelName=homelab \
    --set cloudflare.tunnelId=$CLOUDFLARED_TUNNEL_ID \
    --set cloudflare.secret=$CLOUDFLARED_TUNNEL_SECRET 

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
