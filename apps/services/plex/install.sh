#!/bin/bash

set -e
# source projects/plex/.env

echo "Please enter your Plex Claim token:"
read -r PLEX_CLAIM

# install without flux (easier to deal with the claim token)
kubectl create namespace plex || true
kubectl label namespace plex \
  pod-security.kubernetes.io/enforce=privileged \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn=privileged \
  pod-security.kubernetes.io/warn-version=latest \
  pod-security.kubernetes.io/audit=privileged \
  pod-security.kubernetes.io/audit-version=latest

helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
helm upgrade --install plex plex/plex-media-server \
  --namespace plex \
  --values apps/services/plex/values.yaml \
  --set extraEnv.PLEX_CLAIM=$PLEX_CLAIM

kubectl apply -f ./apps/services/plex/ingress.yaml