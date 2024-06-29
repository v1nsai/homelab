#!/bin/bash

set -e
source projects/personal-site/secrets.env

if [ -z "$WORDPRESS_PASSWORD" ] || [ -z "$MARIADB_PASSWORD" ]; then
    echo "Please set WORDPRESS_PASSWORD and MARIADB_PASSWORD in projects/personal-site/secrets.env"
    exit 1
fi

read -sn1 -p "Delete before installing? [y/N] " DELETE
if [ "$DELETE" == "y" ] || [ "$DELETE" == "Y" ]; then
    helm delete -n personal-site personal-site || true
    kubectl delete ns personal-site || true
    kubectl create ns personal-site || true
fi

kubectl create secret generic wordpress-password \
    --namespace personal-site \
    --from-literal=wordpress-password=${WORDPRESS_PASSWORD} || true

kubectl create secret generic externaldb-password \
    --namespace personal-site \
    --from-literal=mariadb-password=${MARIADB_PASSWORD} || true

helm delete -n personal-site personal-site || true
helm upgrade --install personal-site oci://registry-1.docker.io/bitnamicharts/wordpress \
    --namespace personal-site \
    --set wordpressUsername=doctor_ew \
    --set existingSecret=wordpress-password \
    --set externalDatabase.existingSecret=externaldb-password
    # --set global.storageClass=microk8s-hostpath