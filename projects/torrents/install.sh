#!/bin/bash

set -e

kubectl create secret generic wireguard-config \
    --namespace plex \
    --from-file=projects/torrents/config/gluetun/wg0.conf
kubectl apply \
    --namespace plex \
    --filename projects/torrents/torrents.yaml

# forward port 9091
kubectl port-forward \
    --namespace plex \
    container 9091:9091