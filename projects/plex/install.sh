#!/bin/bash

set -e
source projects/plex/.env
# kubectl apply -f projects/plex/blackbox.yaml
# kubectl logs --selector app=csi-nfs-controller -n kube-system -c nfs

helm uninstall -n plex plex || true

git clone git@github.com:munnerz/kube-plex.git projects/plex/kube-plex || true
source projects/plex/.env
kubectl create namespace plex || true
helm install plex ./projects/plex/kube-plex/charts/kube-plex \
    --namespace plex \
    --set claimToken=$PLEX_CLAIM \
    --set timezone=America/New_York \
    --set ingress.enabled=true \
    --set ingress.hosts[0]=$URL \
    --set ingress.annotations."kubernetes\.io/ingress\.class"=traefik \
    --set ingress.annotations."kubernetes\.io/tls-acme"=true 
    # --set service.type=ClusterIP 
    # --set service.nodePort=32400
    # --set service.externalTrafficPolicy=Local
    # --set persistence.transcode.storageClass=nfs \
    # --set persistence.data.storageClass=nfs \
    # --set persistence.config.storageClass=nfs 