#!/bin/bash

set -e

echo "Setting up microk8s ceph addon..."
sudo microk8s enable rook-ceph
sudo microk8s helm repo add rook-release https://charts.rook.io/release
sudo microk8s connect-external-ceph
#     --ceph-conf /var/snap/microceph/current/conf/ceph.conf \
#     --keyring /var/snap/microceph/current/conf/ceph.keyring \
#     --rbd-pool-auto-create \
#     --rbd-pool microk8s-rbd

# echo "Setting up rook-ceph operator manually due to https://github.com/canonical/microk8s/issues/4314..."
# helm repo add rook-release https://charts.rook.io/release
# helm install rook-ceph rook-release/rook-ceph \
#     --create-namespace \
#     --namespace rook-ceph \
#     --set csi.kubeleteDirPath=/var/snap/microk8s/current/var/lib/kubelet \
#     --set allowLoopDevices=true \
#     --debug
#     # --version

# helm install rook-ceph-cluster rook-release/rook-ceph-cluster \
#     --create-namespace \
#     --namespace rook-ceph-cluster \
#     --values https://raw.githubusercontent.com/rook/rook/master/deploy/charts/rook-ceph-cluster/values-external.yaml \
#     --debug

# # Important Notes:
# # - You must customize the 'CephCluster' resource in the sample manifests for your cluster.
# # - Each CephCluster must be deployed to its own namespace, the samples use `rook-ceph` for the namespace.
# # - The sample manifests assume you also installed the rook-ceph operator in the `rook-ceph` namespace.
# # - The helm chart includes all the RBAC required to create a CephCluster CRD in the same namespace.
# # - Any disk devices you add to the cluster in the 'CephCluster' must be empty (no filesystem and no partitions).