#!/bin/bash

set -e

read -p "Delete deployment and non-media pvcs? [y/N]" DELETE
if [ "$DELETE" == "y" ]; then
    helm delete jellyfin --namespace jellyfin || true
    kubectl delete pvc --namespace jellyfin jellyfin-config || true
fi

flux create source git jellyfin \
  --url https://github.com/v1nsai/jellyfin-helm \
  --branch master \
  --interval 1m \
  --export > projects/jellyfin/app/repository.yaml

flux create helmrelease jellyfin --chart jellyfin \
  --source HelmRepository/jellyfin \
  --namespace jellyfin \
  --values-from Secret/jellyfin-values \
  --export > projects/jellyfin/app/jellyfin.yaml

flux create kustomization jellyfin \
  --source=GitRepository/homelab \
  --path="./projects/jellyfin/app" \
  --prune=true \
  --interval=1h \
  --export > projects/jellyfin/app.yaml