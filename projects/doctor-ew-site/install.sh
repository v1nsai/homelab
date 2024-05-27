#!/bin/bash

set -e
source projects/doctor-ew-site/secrets.env

if [ -z "$WORDPRESS_PASSWORD" ]; then
    echo "Please set the WORDPRESS_PASSWORD environment variable in projects/doctor-ew-site/secrets.env"
    exit 1
fi

kubectl create secret generic wordpress-password \
    --namespace doctor-ew-site \
    --from-literal=wordpress-password=${WORDPRESS_PASSWORD} || true

helm delete -n doctor-ew-site doctor-ew-site || true
helm upgrade --install doctor-ew-site oci://registry-1.docker.io/bitnamicharts/wordpress \
    --namespace doctor-ew-site \
    --set wordpressUsername=doctor_ew \
    --set wordpressPassword=${WORDPRESS_PASSWORD} \
    --set existingSecret=wordpress-password
    # --set mariadb.auth.rootPassword=${MARIADB_ROOT_PASSWORD} \
    # --set mariadb.auth.password=${MARIADB_PASSWORD}