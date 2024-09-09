#!/bin/bash

set -e

kubectl create secret generic wireguard-config \
    --namespace jellyfin \
    --from-file=apps/services/torrents/secrets/gluetun/wg0.conf \
    --dry-run=client \
    -o yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > apps/services/torrents/app/wireguard-config-sealed.yaml
