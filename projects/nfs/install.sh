#!/bin/bash

set -e

# TODO DELETE FOR TESTING ONLY
kubectl delete -f projects/nfs/blackbox.yaml || true
helm uninstall csi-driver-nfs -n kube-system || true

# setup nfs server INSTALL ON ALL NODES
sudo apt install -y nfs-kernel-server nfs-common || true
sudo mkdir -p /mnt/k8s_volumes
sudo chown nobody:nogroup /mnt/k8s_volumes
sudo cp -f /etc/exports.bak /etc/exports
echo "/mnt/k8s_volumes *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -a


# helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
# helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
#     --set nfs.server=192.168.1.214 \
#     --set nfs.path=/mnt/k8s_volumes

# helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
# helm repo update
# helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
#     --namespace kube-system \
#     --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet \
#     --set externalSnapshotter.enabled=true \
#     --set controller.runOnControlPlane=true \
#     --set controller.replicas=2 \
#     --set controller.dnsPolicy=ClusterFirstWithHostNet \
#     --set node.dnsPolicy=ClusterFirstWithHostNet \
#     --set kubeletDir="/var/snap/microk8s/common/var/lib/kubelet"
