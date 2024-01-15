#!/bin/bash

set -e

# REMOVE FOR TESTING ONLY
# helm -n nextcloud uninstall nextcloud || true

echo "Generating or retrieving credentials..."
source projects/nextcloud/secrets.env
NC_ADMIN_SECRET_NAME=nextcloud-admin
NC_NAMESPACE=nextcloud
MARIADB_SECRET_NAME=mariadb-passwords
STORAGECLASS=ceph-rbd

if kubectl get secrets -n nextcloud | grep -q "$NC_ADMIN_SECRET_NAME"; then
    echo "Secret $NC_ADMIN_SECRET_NAME already exists"
else
    echo "Generating $NC_ADMIN_SECRET_NAME..."
    NC_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret -n $NC_NAMESPACE generic $NC_ADMIN_SECRET_NAME \
        --from-literal=nextcloud-password=$NC_PASSWORD \
        --from-literal=nextcloud-host=$NC_HOST \
        --from-literal=nextcloud-username=admin \
        --from-literal=nextcloud-token=$NC_PASSWORD \
        --from-literal=smtp-password=$SMTP_PASS \
        --from-literal=smtp-host=$SMTP_HOST \
        --from-literal=smtp-port=$SMTP_PORT \
        --from-literal=smtp-username=$SMTP_USER
fi

if kubectl get secrets -n nextcloud | grep -q $MARIADB_SECRET_NAME; then
    echo "Secret mariadb-passwords already exists"
else
    echo "Generating mariadb-passwords..."
    MARIADB_PASSWORD=$(openssl rand -base64 20)
    MARIADB_ROOT_PASSWORD=$(openssl rand -base64 20)
    MARIADB_REPLICATION_PASSWORD=$(openssl rand -base64 20)
    kubectl create secret -n nextcloud generic $MARIADB_SECRET_NAME \
        --from-literal=mariadb-password=$MARIADB_PASSWORD \
        --from-literal=password=$MARIADB_PASSWORD \
        --from-literal=mariadb-root-password=$MARIADB_ROOT_PASSWORD \
        --from-literal=mariadb-replication-password=$MARIADB_REPLICATION_PASSWORD
fi


# echo "Uncommenting and setting values.yaml..."
# curl -o projects/nextcloud/values.yaml https://raw.githubusercontent.com/nextcloud/helm/main/charts/nextcloud/values.yaml
# # remove comments from lines between ingress.annotations and ingress.labels
# awk '
# BEGIN { remove_comment = 0; }
# /^  annotations: \{\}/ { remove_comment = 1; print; next; }
# /^  labels: \{\}/ { remove_comment = 0; }
# remove_comment && /^  #/ { sub(/^  #/, "  "); }
# { print; }
# ' projects/nextcloud/values.default.yaml > projects/nextcloud/values.yaml

# yq -i '.ingress.enabled                     = true' projects/nextcloud/values.yaml
# yq -i '.ingress.className                   = "nginx"' projects/nextcloud/values.yaml
# yq -i '.ingress.annotations                |= load("projects/nextcloud/ingress_params.yaml")' projects/nextcloud/values.yaml
# yq -i '.nextcloud.host                      = strenv(NC_HOST)' projects/nextcloud/values.yaml
# yq -i '.nextcloud.username                  = "admin"' projects/nextcloud/values.yaml
# yq -i '.nextcloud.existingSecret.enabled    = true' projects/nextcloud/values.yaml
# yq -i '.nextcloud.existingSecret.secretName = strenv(NC_ADMIN_SECRET_NAME)' projects/nextcloud/values.yaml
# yq -i '.internalDatabase.enabled            = false' projects/nextcloud/values.yaml
# yq -i '.externalDatabase.enabled            = true' projects/nextcloud/values.yaml
# yq -i '.mariadb.enabled                     = true' projects/nextcloud/values.yaml
# yq -i '.mariadb.auth.existingSecret         = strenv(MARIADB_SECRET_NAME)' projects/nextcloud/values.yaml
# yq -i '.mariadb.db.password                 = strenv(MARIADB_PASSWORD)' projects/nextcloud/values.yaml
# yq -i '.persistence.enabled                 = true' projects/nextcloud/values.yaml
# yq -i '.persistence.storageClass            = strenv(STORAGECLASS)' projects/nextcloud/values.yaml
# yq -i '.service.type                        = "NodePort"' projects/nextcloud/values.yaml
# yq -i '.service.nodePort                    = 30080' projects/nextcloud/values.yaml

echo "Installing Nextcloud..."
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm upgrade --install nextcloud nextcloud/nextcloud \
    --namespace nextcloud \
    --create-namespace \
    --set ingress.enabled=true \
    --set nextcloud.host=$NC_HOST \
    --set nextcloud.username=admin \
    --set nextcloud.existingSecret.enabled=true \
    --set nextcloud.existingSecret.secretName=$NC_ADMIN_SECRET_NAME \
    --set internalDatabase.enabled=false \
    --set externalDatabase.enabled=true \
    --set mariadb.enabled=true \
    --set persistence.enabled=true \
    --set persistence.storageClass=$STORAGECLASS \
    --set service.type=NodePort \
    --set service.nodePort=30080
#     --set-file ingress.annotations="projects/nextcloud/ingress_params.yaml"
    # --set-json "$INGRESS_PARAMS"
    # --set mariadb.auth.existingSecret=$MARIADB_SECRET_NAME \
    # --set mariadb.primary.persistence.enabled=true \
    # --set mariadb.primary.persistence.storageClass=$STORAGECLASS \
    # --set persistence.nextcloudData.enabled=true \
    # --set persistence.nextcloudData.storageClass=$STORAGECLASS 
    # --values projects/nextcloud/values.yaml

kubectl get events -n nextcloud -w
