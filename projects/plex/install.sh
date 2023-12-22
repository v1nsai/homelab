#!/bin/bash

set -e

# kubectl apply -f projects/plex/blackbox.yaml
# kubectl logs --selector app=csi-nfs-controller -n kube-system -c nfs

git clone git@github.com:munnerz/kube-plex.git projects/plex/kube-plex || true
source projects/plex/.env
kubectl create namespace plex || true
helm install plex ./projects/plex/kube-plex/charts/kube-plex \
    --namespace plex \
    --set claimToken=$PLEX_CLAIM \
    --set service.type=NodePort \
    --set service.nodePort=32500 \
    --set 
    # --set ingress.enabled=true \
    # --set ingress.hosts[0]=kube-plex.doctor-ew.com 
