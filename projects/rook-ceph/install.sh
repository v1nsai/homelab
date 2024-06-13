#!/bin/bash

set -e

# source projects/rook-ceph/secrets.env

helm repo add rook-release https://charts.rook.io/release
helm upgrade --install rook-ceph rook-release/rook-ceph \
    --create-namespace \
    --namespace rook-ceph #\
    # --values projects/rook-ceph/values.yaml

helm upgrade --install ceph-cluster rook-release/rook-ceph-cluster \
    --create-namespace \
    --namespace ceph-cluster #\
    # --values projects/rook-ceph/values.yaml