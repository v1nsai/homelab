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
helm upgrade --install plex plex/plex-media-server \
    --create-namespace \
    --namespace plex \
    --set service.type=LoadBalancer \
    --set extraVolumeMounts[0].name=plex-media \
    --set extraVolumeMounts[0].mountPath=/plex-media \
    --set extraVolumes[0].name=plex-media \
    --set extraVolumes[0].persistentVolumeClaim.claimName=plex-media \
    --set extraVolumeMounts[1].name=the-goods \
    --set extraVolumeMounts[1].mountPath=/the-goods \
    --set extraVolumes[1].name=the-goods \
    --set extraVolumes[1].persistentVolumeClaim.claimName=the-goods \
    --set extraEnv.PLEX_CLAIM="$PLEX_CLAIM"
