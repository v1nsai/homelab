#!/bin/bash

set -e
source cluster/bootstrap/talos/extensions/harbor-registry/.env

# Harbor registry URL and secret
kubectl delete secret harbor-registry-secret --namespace $NAMESPACE || true
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=${HARBOR_SERVER} \
  --docker-username=${HARBOR_USERNAME} \
  --docker-password=${HARBOR_PASSWORD} \
  --docker-email=${HARBOR_EMAIL} \
  --namespace $NAMESPACE

# add harbor to talos cluster
envsubst < cluster/bootstrap/talos/extensions/harbor-registry/registry_patch.template.yaml > /tmp/registry_patch.yaml
talosctlwrapper all patch machineconfig --patch @/tmp/registry_patch.yaml