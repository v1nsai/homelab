#!/bin/bash

set -e

git clone git@github.com:munnerz/kube-plex.git projects/plex/kube-plex || true
source projects/plex/.env
# kubectl apply -f projects/plex/blackbox.yaml

kubectl create namespace plex || true
helm install plex ./projects/plex/kube-plex/charts/kube-plex \
    --namespace plex \
    --set claimToken=$PLEX_CLAIM \
    --set service.type=NodePort \
    --set service.port=32400 \
    --set persistence.data.claimName=blackbox-nfs-pvc

