#!/bin/bash

set -e

# oppenheimer
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm upgrade --install silverstick-nfs-subdir nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace silverstick-provisioner \
    --create-namespace \
    --set nfs.server="192.168.1.162" \
    --set nfs.path="/mnt/silverstick/kubernetes" \
    --set storageClass.name="silverstick" \
    --set storageClass.provisionerName="k8s-sigs.io/silverstick-nfs-subdir-external-provisioner" \
    --set nodeSelector."kubernetes\.io/hostname"="oppenheimer"
    
# bigrig
helm upgrade --install irma-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --create-namespace \
    --namespace irma-provisioner \
    --set nfs.server="192.168.1.170" \
    --set nfs.path="/mnt/irma/kubernetes" \
    --set storageClass.name="irma" \
    --set storageClass.provisionerName="k8s-sigs.io/irma-nfs-subdir-external-provisioner" \
    --set nodeSelector."kubernetes\.io/hostname"="bigrig"

sudo apt install -y nfs-kernel-server nfs-common
echo "/mnt/silverstick *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -a
