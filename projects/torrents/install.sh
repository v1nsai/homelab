#!/bin/bash

set -e

# Delete first for troubleshooting
# kubectl delete secret wireguard-config \
#     --namespace plex || true
# kubectl delete \
#     --namespace plex \
#     --filename projects/torrents/torrents.yaml || true

kubectl create secret generic wireguard-config \
    --namespace plex \
    --from-file=projects/torrents/config/gluetun/wg0.conf || true

kubectl apply \
    --namespace plex \
    --filename projects/torrents/torrents.yaml

# Reboot qbittorrent container since it can't connect to network if both are started at the same time
echo "Sleeping and then restarting qbittorrent container..."
sleep 10
kubectl exec -it \
    --namespace plex \
    $(kubectl get pods \
        --namespace plex \
        --selector=app=qbittorrent-gluetun \
        --output=jsonpath='{.items[0].metadata.name}') \
    --container qbittorrent \
    -- reboot