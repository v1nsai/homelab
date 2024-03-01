#!/bin/bash

set -e
source projects/plex/.env
# kubectl apply -f projects/plex/plex-media-pvc.yaml

# helm uninstall -n plex plex || true

git clone git@github.com:munnerz/kube-plex.git projects/plex/kube-plex || true
helm install plex ./projects/plex/kube-plex/charts/kube-plex \
    --namespace plex \
    --create-namespace \
    --set claimToken=$PLEX_CLAIM \
    --set timezone=America/New_York \
    --set service.type=LoadBalancer \
    --set persistence.extraData[0].name=plex-media \
    --set persistence.extraData[0].claimName=plex-media 