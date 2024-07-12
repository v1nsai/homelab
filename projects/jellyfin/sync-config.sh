#!/bin/bash

set -e

# Jellyfin uses sqlite as its database, which get weird over network storage
# This script is a sloppy solution to keeping jellyfin backed up until I figure out a velero-friendly storageclass to use

JELLYFIN_POD=$(kubectl get pods -n jellyfin | grep jellyfin | awk '{print $1}')
kubectl exec -it -n jellyfin $JELLYFIN_POD -- apt update
kubectl exec -it -n jellyfin $JELLYFIN_POD -- apt install -y rsync
kubectl exec -it -n jellyfin $JELLYFIN_POD -- rm -rf /media/jellyfin-backup/config
kubectl exec -it -n jellyfin $JELLYFIN_POD -- mkdir -p /media/jellyfin-backup/config
kubectl exec -it -n jellyfin $JELLYFIN_POD -- rsync -av /config/ /media/jellyfin-backup/config

# add script to crontabs
# cp -f projects/jellyfin/sync-config.sh /etc/cron.daily/sync-config.sh