#!/bin/bash

set -e

# if projects/calibre/.env not found, create it
if [ ! -f projects/calibre/.env ]; then
    echo "Creating projects/calibre/.env..."
    echo "PROJECT_NAME=calibre" > projects/calibre/.env
    echo "Please enter a password for calibre:"
    read -s CALIBRE_PASSWORD
    echo "Please re-enter the password for calibre:"
    read -s CALIBRE_PASSWORD_CONFIRM
    if [ "$CALIBRE_PASSWORD" != "$CALIBRE_PASSWORD_CONFIRM" ]; then
        echo "Passwords do not match. Exiting..."
        exit 1
    fi
else
    echo "Using existing projects/calibre/.env..."
fi

source projects/calibre/.env
scripts/kompose.sh calibre

echo "Updating config files..."
yq e -i '.spec.template.spec.containers[0].env |= map(select(.name == "PASSWORD").value = "'$CALIBRE_PASSWORD'")' projects/calibre/kompose/templates/calibre-deployment.yaml # Set the db password

echo "Configuring services..."
yq e -i '.spec.type = "LoadBalancer"' projects/calibre/kompose/templates/calibre-service.yaml
# yq e -i '.spec.type = "LoadBalancer"' projects/calibre/kompose/templates/calibre-web-service.yaml

echo "Configuring storage..."
for file in projects/calibre/kompose/templates/calibre-*.yaml; do
    if [[ $file == *"claim"* ]]; then
        yq e -i '.spec.storageClassName = "nfs-client"' $file
    fi
done
yq e -i '.spec.resources.requests.storage = "50Gi"' projects/calibre/kompose/templates/calibre-web-media-persistentvolumeclaim.yaml
yq e -i '.spec.resources.requests.storage = "50Gi"' projects/calibre/kompose/templates/calibre-config-persistentvolumeclaim.yaml

echo "Updating namespace for all objects..."
for file in projects/calibre/kompose/templates/*.yaml; do
    yq e -i '.metadata.namespace = "calibre"' $file
done

echo "Deploying calibre..."
helm upgrade --install calibre projects/calibre/kompose \
    --namespace calibre \
    --create-namespace
