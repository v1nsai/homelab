#!/bin/bash

set -e

helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --create-namespace \
    --set externalSnapshotter.enabled=true \
    --set controller.replicas=2

# oppenheimer
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm upgrade --install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace kube-system \
    --set nfs.server="192.168.1.162" \
    --set nfs.path="/mnt/silverstick/kubernetes"

# bigrig
helm upgrade --install irma-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --create-namespace \
    --namespace irma-provisioner \
    --set nfs.server="192.168.1.169" \
    --set nfs.path="/mnt/irma/kubernetes" \
    --set storageClass.name="irma" \
    --set storageClass.provisionerName="k8s-sigs.io/irma-nfs-subdir-external-provisioner"

echo "/mnt/silverstick *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -a
