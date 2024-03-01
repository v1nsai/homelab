#!/bin/bash

set -e
source projects/plex/.env

# scripts/kompose.sh plex

yq e -i '.name = "plex"' projects/plex/kompose/Chart.yaml # set the name
yq e -i '.spec.replicas = 3' projects/plex/kompose/templates/plex-deployment.yaml # set the replicas
yq e -i '.spec.template.spec.containers[0].env |= map(select(.name == "PLEX_CLAIM").value = "'$PLEX_CLAIM'")' projects/plex/kompose/templates/plex-deployment.yaml # Set the plex claim
yq e -i '.spec.type = "LoadBalancer"' projects/plex/kompose/templates/plex-service.yaml # set the service type

# for file in projects/plex/kompose/templates/*.yaml; do
#     yq e -i '.metadata.namespace = "plex"' $file # set the namespace
# done

# cp -f projects/plex/plex-ingress.yaml projects/plex/kompose/templates/plex-ingress.yaml # copy the ingress

helm delete -n plex plex || true
helm upgrade --install plex projects/plex/kompose \
    --namespace plex \
    --create-namespace
