#!/bin/bash

set -e

# source projects/rook-ceph/secrets.env

read -sn1 -p "Delete existing rook-ceph and rook-cluster deploys? [y/N] " delete
if [[ $delete == [yY] ]]; then
    projects/rook-ceph/uninstall.sh
fi

helm repo add rook-release https://charts.rook.io/release
helm repo update
cat projects/rook-ceph/operator/helmrelease.yaml | yq '.spec.values' > /tmp/rook-ceph.values.yaml
helm upgrade --install rook-ceph rook-release/rook-ceph \
    --create-namespace \
    --namespace rook-ceph \
    --values /tmp/rook-ceph.values.yaml

cat projects/rook-ceph/cluster/helmrelease.yaml | yq '.spec.values' > /tmp/rook-ceph-cluster.values.yamls
helm upgrade --install rook-ceph-cluster rook-release/rook-ceph-cluster \
    --create-namespace \
    --namespace rook-ceph \
    --values /tmp/rook-ceph-cluster.values.yamls
