#!/bin/bash

set -e

source apps/services/pihole/.env
scripts/kompose.sh pihole

echo "Updating config files..."
yq e -i '.spec.template.spec.containers[0].env |= map(select(.name == "WEBPASSWORD").value = "'$WEBPASSWRD'")' apps/services/pihole/kompose/templates/pihole-deployment.yaml # Set the web password

yq e -i '.spec.type = "LoadBalancer"' apps/services/pihole/kompose/templates/pihole-service.yaml

for file in apps/services/pihole/kompose/templates/pihole-*.yaml; do
    if [[ $file == *"claim"* ]]; then
        yq e -i '.spec.storageClassName = "nfs-client"' $file # set the storage class
    fi
done

echo "Deploying pihole..."
helm upgrade --install pihole apps/services/pihole/kompose --namespace pihole --create-namespace
