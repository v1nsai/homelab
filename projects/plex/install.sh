#!/bin/bash

# set -e
# source projects/plex/.env

# scripts/kompose.sh plex

# yq e -i '.name = "plex"' projects/plex/kompose/Chart.yaml # set the name
# yq e -i '.spec.replicas = 3' projects/plex/kompose/templates/plex-deployment.yaml # set the replicas
# yq e -i '.spec.template.spec.containers[0].env |= map(select(.name == "PLEX_CLAIM").value = "claim-RsCyecdLrx9o6szBzQsq")' projects/plex/kompose/templates/plex-deployment.yaml # Set the plex claim

# for file in projects/plex/kompose/templates/*.yaml; do
#     yq e -i '.metadata.namespace = "plex"' $file # set the namespace
# done

cp -f projects/plex/plex-ingress.yaml projects/plex/kompose/templates/plex-ingress.yaml # copy the ingress

helm upgrade --install plex projects/plex/kompose \
    --namespace plex \
    --create-namespace
