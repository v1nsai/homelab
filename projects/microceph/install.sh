#!/bin/bash

set -e

## Use on master node
echo "Setting up microceph..."
sudo snap install microceph
# sudo snap refresh --hold microceph # hold updates
# sudo microceph cluster bootstrap
# sudo microceph cluster add $hostname_of_node

## On worker nodes
# sudo snap install microceph
# sudo snap refresh --hold microceph # hold updates
# sudo microceph cluster join <token from running `microceph cluster add` on master>

# Add external disks here
sudo microceph disk add --wipe /dev/sda

echo "Setting up microk8s ceph addon..."
# sudo REQUIRED to make these work, will "successfully" fail otherwise
sudo microk8s enable rook-ceph
sudo microk8s helm repo add rook-release https://charts.rook.io/release
sudo microk8s connect-external-ceph

# set ceph as default StorageClass
kubectl patch storageclass ceph-rbd -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'