#!/bin/bash

set -e

helm delete -n traefik traefik || echo "traefik not found, skipping delete..."
nodeIPs=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' | tr ' ' ',')
helm upgrade --install traefik traefik/traefik \
    --create-namespace \
    --namespace traefik \
    --set hostNetwork=true \
    --set service.externalIPs={${nodeIPs}}

    # --set ports.web.port=80 \
    # --set ports.web.hostPort=80 \
    # --set ports.web.exposedPort=80 \
    # --set ports.web.containerPort=80 \
    # --set ports.websecure.port=443 \
    # --set ports.websecure.hostPort=443 \
    # --set ports.websecure.exposedPort=443 \
    # --set ports.websecure.containerPort=443
