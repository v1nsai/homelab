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
    --set ingress.annotations."kubernetes\.io/ingress\.class"=traefik \
    --set ingress.annotations."kubernetes\.io/tls-acme"=true \
    --set ingress.annotations."traefik\.ingress\.kubernetes.io/router\.tls"=true \
    --set ingress.annotations."traefik\.ingress\.kubernetes\.io/router\.entrypoints"=https \
    --set ingress.annotations."traefik\.ingress\.kubernetes\.io/router\.tls\.certresolver"=letsencrypt-staging \
    --set ingress.annotations."traefik\.ingress\.kubernetes\.io/router\.tls\.domains[0].main"=$PLEX_URL 

    # --set ingress.hosts[0]=$PLEX_URL \
    # --set service.type=ClusterIP 
    # --set service.nodePort=32400
    # --set service.externalTrafficPolicy=Local
    # --set persistence.transcode.storageClass=nfs \
    # --set persistence.data.storageClass=nfs \
    # --set persistence.config.storageClass=nfs 