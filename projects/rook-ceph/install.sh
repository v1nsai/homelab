#!/bin/bash

set -e

# source projects/rook-ceph/secrets.env

read -sn1 -p "Delete existing rook-ceph and ceph-cluster deploys? [y/N] " delete
if [[ $delete == [yY] ]]; then
    helm delete -n rook-ceph rook-ceph
    helm delete -n ceph-cluster ceph-cluster
    kubectl delete namespace rook-ceph ceph-cluster
fi

helm repo add rook-release https://charts.rook.io/release
helm upgrade --install ceph-cluster rook-release/rook-ceph \
    --create-namespace \
    --namespace rook-ceph

helm upgrade --install ceph-cluster rook-release/rook-ceph-cluster \
    --create-namespace \
    --namespace ceph-cluster \
    --values projects/rook-ceph/ceph-cluster.values.yaml
