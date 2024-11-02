#!/bin/bash

set -e
# source projects/plex/.env

echo "Please enter your Plex Claim token:"
read -r PLEX_CLAIM

cat <<EOF > /tmp/secret-values.yaml
extraEnv:
  PLEX_CLAIM: $PLEX_CLAIM
EOF
kubectl create secret generic secret-values \
    --namespace=plex \
    --from-file=/tmp/secret-values.yaml \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > ./apps/services/plex/app/sealed-secrets.yaml

# install no flux
kubectl create namespace plex
kubectl label namespace plex \
  pod-security.kubernetes.io/enforce=privileged \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn=privileged \
  pod-security.kubernetes.io/warn-version=latest \
  pod-security.kubernetes.io/audit=privileged \
  pod-security.kubernetes.io/audit-version=latest

source apps/services/plex/.env
helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
helm upgrade --install plex plex/plex-media-server \
  --namespace plex \
  --set extraEnv.PLEX_CLAIM=$PLEX_CLAIM \
  --values apps/services/plex/values.yaml