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

echo "Setting up qbittorrent custom UI..."
# latest_release=$(curl -s -L -o /dev/null -w "%{url_effective}" https://github.com/VueTorrent/VueTorrent/releases/latest | sed 's/releases\/tag/releases\/download/g')
# wget "$latest_release/vuetorrent.zip" -O projects/torrents/config/vuetorrent.zip
# unzip projects/torrents/config/vuetorrent.zip -d projects/torrents/config/vuetorrent
kubectl cp projects/torrents/config/vuetorrent/vuetorrent \
    --namespace plex \
    $(kubectl get pods \
        --namespace plex \
        --selector=app=qbittorrent-gluetun \
        --output=jsonpath='{.items[0].metadata.name}'):/downloads \
    --container qbittorrent

echo "Sleeping and then restarting qbittorrent container..."
sleep 5
kubectl exec -it \
    --namespace plex \
    $(kubectl get pods \
        --namespace plex \
        --selector=app=qbittorrent-gluetun \
        --output=jsonpath='{.items[0].metadata.name}') \
    --container qbittorrent \
    -- reboot

