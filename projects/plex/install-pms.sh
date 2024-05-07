#!/bin/bash

set -e
source projects/plex/.env

# if [ $(kubectl get pvc -n plex plex-media | wc -l) -lt 2 ]; then
#     kubectl apply -f projects/plex/plex-media-pvc.yaml
# fi

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

# PLEX_MEDIA_PATH=$(ls -d /mnt/silverstick/kubernetes/*plex-plex-media-pvc*)
# ln -s /mnt/silverstick/torrents/ $PLEX_MEDIA_PATH/torrents

# get a shell inside the plex container
kubectl exec -it -n plex plex-plex-media-server-0 -- /bin/bash