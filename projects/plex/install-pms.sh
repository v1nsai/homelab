#!/bin/bash

set -e
source projects/plex/.env

helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
helm upgrade --install plex plex/plex-media-server \
    --create-namespace \
    --namespace plex \
    --set service.type=LoadBalancer \
    --set extraVolumeMounts[0].name=plex-media \
    --set extraVolumeMounts[0].mountPath=/plex-media \
    --set extraVolumes[0].name=plex-media \
    --set extraVolumes[0].persistentVolumeClaim.claimName=plex-media \
    --set extraEnv.PLEX_CLAIM="$PLEX_CLAIM"