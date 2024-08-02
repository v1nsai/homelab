#!/bin/bash

set -e

# Use to install before restoring a cluster

helm repo add rook-release https://charts.rook.io/release
helm repo update
cat projects/rook-ceph/operator/helmrelease.yaml | yq '.spec.values' > /tmp/rook-ceph.values.yaml
helm upgrade --install rook-ceph rook-release/rook-ceph \
    --create-namespace \
    --namespace rook-ceph \
    --values /tmp/rook-ceph.values.yaml

cat projects/rook-ceph/cluster/helmrelease.yaml | yq '.spec.values' > /tmp/rook-ceph-cluster.values.yaml
helm upgrade --install rook-ceph-cluster rook-release/rook-ceph-cluster \
    --create-namespace \
    --namespace rook-ceph \
    --values /tmp/rook-ceph-cluster.values.yaml
