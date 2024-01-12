#!/bin/bash

set -e

helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
helm upgrade --install plex plex/plex-media-server \
    --set pms.storageClassName=ceph-rbd \
    --set ingress.enabled=true \
    --set ingress.ingressClassName=traefik \
    --set serviceAccount.name=plex-svcacct \
