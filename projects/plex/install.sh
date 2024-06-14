#!/bin/bash

set -e
# source projects/plex/.env

read -p "Delete existing installation? (y/N)" DELETE
if [ "$DELETE" == "y" ]; then
    helm delete plex -n plex
    kubectl delete -n plex pvc pms-config-plex-plex-media-server-0
    read -p "Enter current plex claim token: " PLEX_CLAIM
fi
helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
helm repo update
helm upgrade --install plex plex/plex-media-server \
    --create-namespace \
    --namespace plex \
    --values projects/plex/values.yaml \
    --set extraEnv.PLEX_CLAIM="$PLEX_CLAIM"

# set runtimeClassName for plex pod
# kubectl patch pod plex-plex-media-server-0 -n plex --type='json' -p='[{"op": "add", "path": "/spec/runtimeClassName", "value": "nvidia"}]'