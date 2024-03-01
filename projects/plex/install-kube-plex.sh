#!/bin/bash

set -e
source projects/plex/.env
# kubectl apply -f projects/plex/blackbox.yaml
# kubectl logs --selector app=csi-nfs-controller -n kube-system -c nfs

helm uninstall -n plex plex || true

git clone git@github.com:munnerz/kube-plex.git projects/plex/kube-plex || true
helm install plex ./projects/plex/kube-plex/charts/kube-plex \
    --namespace plex \
    --create-namespace \
    --set claimToken=$PLEX_CLAIM \
    --set timezone=America/New_York \
    --set ingress.enabled=true \
    --set ingress.hosts[0]=$PLEX_URL
