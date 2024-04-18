#!/bin/bash

set -e

echo "Configuring project servarr..."
scripts/kompose.sh --chart servarr
# values.yaml
yq eval -i '.prowlarr.prowlarr.env.tz = "America/New_York"' projects/servarr/kompose/values.yaml
yq eval -i '.prowlarr.type = "LoadBalancer"' projects/servarr/kompose/values.yaml
yq eval -i '.pvc.claim0.storageRequest = "10Gi"' projects/servarr/kompose/values.yaml
# Chart.yaml
yq eval -i '.name = "servarr"' projects/servarr/kompose/Chart.yaml

echo "Deploying project servarr..."
helm upgrade --install servarr projects/servarr/kompose/ \
    --namespace servarr \
    --create-namespace
