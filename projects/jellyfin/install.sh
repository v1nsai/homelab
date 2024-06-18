#!/bin/bash

set -e

# git clone git@github.com:jellyfin/jellyfin-helm.git projects/jellyfin/jellyfin-helm

read -p "Delete deployment and non-media pvcs? [y/N]" DELETE
if [ "$DELETE" == "y" ]; then
    helm delete jellyfin --namespace jellyfin || true
    kubectl delete pvc --namespace jellyfin jellyfin-config || true
fi

helm upgrade --install jellyfin ./projects/jellyfin/jellyfin-helm/charts/jellyfin \
    --namespace jellyfin \
    --create-namespace \
    --values projects/jellyfin/values.yaml
