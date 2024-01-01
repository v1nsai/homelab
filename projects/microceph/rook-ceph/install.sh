#!/bin/bash

set -e

# echo "Setting up microk8s ceph addon..."
# microk8s enable rook-ceph
# sudo microk8s connect-external-ceph \
#     --ceph-conf /var/snap/microceph/current/conf/ceph.conf \
#     --keyring /var/snap/microceph/current/conf/ceph.keyring \
#     --rbd-pool-auto-create \
#     --rbd-pool microk8s-rbd

echo "Setting up rook-ceph operator manually due to https://github.com/canonical/microk8s/issues/4314..."
helm repo add rook-release https://charts.rook.io/release
helm install rook-ceph rook-release/rook-ceph \
    --create-namespace \
    --namespace rook-ceph \
    --set allowLoopDevices=true 

helm install rook-ceph-cluster rook-release/rook-ceph-cluster \
    --create-namespace \
    --namespace rook-ceph-cluster \
    --values projects/microceph/rook-ceph/values-external-cluster.yaml 
    # --values https://raw.githubusercontent.com/rook/rook/master/deploy/charts/rook-ceph-cluster/values-external.yaml