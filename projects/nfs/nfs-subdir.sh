#!/bin/bash

set -e

# oppenheimer
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm upgrade --install silverstick-nfs-subdir nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --namespace silverstick-provisioner \
    --create-namespace \
    --values projects/nfs/nfs-subdir.silverstick.values.yaml
    
# bigrig
helm upgrade --install irma-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --create-namespace \
    --namespace irma-provisioner \
    --values projects/nfs/nfs-subdir.irma.values.yaml

sudo apt install -y nfs-kernel-server nfs-common
echo "/mnt/silverstick *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -a
