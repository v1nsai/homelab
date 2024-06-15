#!/bin/bash

set -e

read -p "Delete deployment and non-media pvcs? [y/N]" DELETE
if [ "$DELETE" == "y" ]; then
    kubectl delete \
        --namespace jellyfin \
        --filename projects/torrents/torrents.yaml || true
fi

read -p "Recreate wireguard-config secret? [y/N]" RECREATE_SECRET
if [ "$RECREATE_SECRET" == "y" ]; then
    kubectl delete secret wireguard-config \
        --namespace jellyfin || true
fi

kubectl create secret generic wireguard-config \
    --namespace jellyfin \
    --from-file=projects/torrents/config/gluetun/wg0.conf || true

kubectl apply \
    --namespace jellyfin \
    --filename projects/torrents/torrents.yaml

echo "Setting up qbittorrent custom UI..."
# latest_release=$(curl -s -L -o /dev/null -w "%{url_effective}" https://github.com/VueTorrent/VueTorrent/releases/latest | sed 's/releases\/tag/releases\/download/g')
# wget "$latest_release/vuetorrent.zip" -O projects/torrents/config/vuetorrent.zip
# unzip projects/torrents/config/vuetorrent.zip -d projects/torrents/config/vuetorrent
kubectl cp projects/torrents/config/vuetorrent/ \
    --namespace jellyfin \
    $(kubectl get pods \
        --namespace jellyfin \
        --selector=app=qbittorrent-gluetun \
        --output=jsonpath='{.items[0].metadata.name}'):/config \
    --container qbittorrent

# echo "Sleeping and then restarting qbittorrent container..."
# sleep 5
# kubectl exec -it \
#     --namespace jellyfin \
#     $(kubectl get pods \
#         --namespace jellyfin \
#         --selector=app=qbittorrent-gluetun \
#         --output=jsonpath='{.items[0].metadata.name}') \
#     --container qbittorrent \
#     -- reboot

