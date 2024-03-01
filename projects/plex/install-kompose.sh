#!/bin/bash

set -e
source projects/plex/.env

# scripts/kompose.sh plex

yq e -i '.name = "plex"' projects/plex/kompose/Chart.yaml # set the name

# yq e -i '.spec.replicas = 3' projects/plex/kompose/templates/plex-deployment.yaml # set the replicas
yq e -i '.spec.template.spec.containers[0].env |= map(select(.name == "PLEX_CLAIM").value = "'$PLEX_CLAIM'")' projects/plex/kompose/templates/plex-deployment.yaml # Set the plex claim
sed -i 's/plex-claim0/plex-media/g' projects/plex/kompose/templates/plex-deployment.yaml # set the pvc to the shared one

yq e -i '.spec.type = "LoadBalancer"' projects/plex/kompose/templates/plex-service.yaml # set the service type

rm -rf projects/plex/kompose/templates/plex-claim*.yaml # remove the auto generated claim

for file in projects/plex/kompose/templates/*.yaml; do
    yq e -i '.metadata.namespace = "plex"' $file # set the namespace
done

# cp -f projects/plex/plex-media-pvc.yaml projects/plex/kompose/templates/plex-media-pvc.yaml # copy the ingress

helm delete -n plex plex || true
helm upgrade --install plex projects/plex/kompose \
    --namespace plex \
    --create-namespace
