#!/bin/bash

set -e

read -p "Recreate wireguard-config secret? [y/N]" RECREATE_SECRET
if [ "$RECREATE_SECRET" == "y" ]; then
    # kubectl delete secret wireguard-config \
    #     --namespace jellyfin || true
    kubectl create secret generic wireguard-config \
        --namespace jellyfin \
        --from-file=projects/torrents/secrets/gluetun/wg0.conf \
        --dry-run=client \
        -o yaml | \
    kubeseal \
        --format=yaml \
        --cert=./.sealed-secrets.pub > projects/torrents/app/wireguard-config-sealed.yaml
fi
