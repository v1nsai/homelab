#!/bin/bash

set -e

source projects/pihole/.env
scripts/kompose.sh pihole

echo "Updating config files..."
yq e -i '.spec.template.spec.containers[0].env |= map(select(.name == "WEBPASSWORD").value = "'$WEBPASSWRD'")' projects/pihole/kompose/templates/pihole-deployment.yaml # Set the web password

yq e -i '.spec.type = "LoadBalancer"' projects/pihole/kompose/templates/pihole-service.yaml

for file in projects/pihole/kompose/templates/pihole-*.yaml; do
    if [[ $file == *"claim"* ]]; then
        yq e -i '.spec.storageClassName = "nfs-client"' $file # set the storage class
    fi
done

echo "Deploying pihole..."
helm upgrade --install pihole projects/pihole/kompose --namespace pihole --create-namespace
