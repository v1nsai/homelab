#!/bin/bash

set -e

# kubectl apply -f projects/plex/blackbox.yaml
# kubectl logs --selector app=csi-nfs-controller -n kube-system -c nfs

helm uninstall -n plex plex || true

git clone git@github.com:munnerz/kube-plex.git projects/plex/kube-plex || true
source projects/plex/.env
kubectl create namespace plex || true
helm install plex ./projects/plex/kube-plex/charts/kube-plex \
    --namespace plex \
    --set claimToken=$PLEX_CLAIM \
    --set timezone=America/New_York 
    # --set service.type=NodePort \
    # --set service.nodePort=32400
    # --set service.externalTrafficPolicy=Local
    # --set persistence.transcode.storageClass=nfs \
    # --set persistence.data.storageClass=nfs \
    # --set persistence.config.storageClass=nfs 
    # --set ingress.enabled=false \
    # --set ingress.hosts[0]=plex.doctor-ew.com \
    # --set ingress.annotations."kubernetes\.io/ingress\.class"=nginx \
    # --set ingress.annotations."kubernetes\.io/tls-acme"=false \
