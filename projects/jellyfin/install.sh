#!/bin/bash

set -e

# git clone git@github.com:jellyfin/jellyfin-helm.git projects/jellyfin/jellyfin-helm

# bash command prompt user "Delete deployment and pvcs? [y/n]" and put it into a variable called DELETE
read -p "Delete deployment and non-media pvcs? [y/N]" DELETE
if [ "$DELETE" == "y" ]; then
    helm delete jellyfin --namespace jellyfin || true
    kubectl delete pvc --namespace jellyfin jellyfin-config || true
fi

helm upgrade --install jellyfin ./projects/jellyfin/jellyfin-helm/charts/jellyfin \
    --namespace jellyfin \
    --create-namespace \
    --values projects/jellyfin/values.yaml

kubectl exec -it $(kubectl get pods -n jellyfin | grep jellyfin | awk '{print $1}') -n jellyfin -- /bin/bash -c 'echo "0 3 * * * rsync -av --delete /config /media/jellyfin-config-backup" > /etc/cron.d/jellyfin-config-backup'

# check for file lock on /config/data/jellyfin.db sqlite database
