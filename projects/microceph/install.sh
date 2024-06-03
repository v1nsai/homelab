#!/bin/bash

set -e
source projects/microceph/secrets.env

if [ -z "$CEPH_ADMIN_KEY" ]; then
    echo "CEPH_ADMIN_KEY not set in projects/microceph/secrets.env"
    exit 1
fi

## Use on master node
# echo "Setting up microceph..."
# sudo snap install microceph
# sudo snap refresh --hold microceph # hold updates
# sudo microceph cluster bootstrap
# sudo microceph cluster add $hostname_of_node

## On worker nodes
# sudo snap install microceph
# sudo snap refresh --hold microceph # hold updates
# sudo microceph cluster join <token from running `microceph cluster add` on master>

# Add external disks here
# sudo microceph disk add --wipe /dev/sda

# Create cephfs
# ceph osd pool create cephfs_data 64
# ceph osd pool create cephfs_metadata 64
# ceph fs new cephfs-homelab cephfs_metadata cephfs_data

# set ceph as default StorageClass
# kubectl patch storageclass ceph-rbd -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
# kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# if kubectl get secret csi-cephfs-secret -n ceph-csi &> /dev/null; then
#     echo "Ceph CSI secret already exists, skipping creation..."
# else
#     echo "Creating Ceph CSI secret..."
#     kubectl create secret generic csi-cephfs-secret \
#         --namespace ceph-csi \
#         --from-literal=adminID="client.admin" \
#         --from-literal=adminKey="$CEPH_ADMIN_KEY" 
# fi

echo "Installing ceph-csi..."
echo "Delete first? [y/N]"
read -r DELETE
if [ "$DELETE" == "y" ]; then
    helm delete -n ceph-csi ceph-csi
    sleep 5
fi
helm repo add ceph-csi https://ceph.github.io/csi-charts
helm repo update
helm upgrade --install ceph-csi ceph-csi/ceph-csi-cephfs \
    --create-namespace \
    --namespace ceph-csi \
    --set secret.adminKey="$CEPH_ADMIN_KEY" \
    --values projects/microceph/ceph-csi-values.yaml

    # --set storageClass.mounter="kernel" \

# echo "Setting up microk8s ceph addon..."
# # sudo REQUIRED to make these work, will "successfully" fail otherwise
# sudo microk8s enable rook-ceph
# sudo microk8s helm repo add rook-release https://charts.rook.io/release
# sudo microk8s connect-external-ceph

# Ceph dashboard
sudo microceph.ceph config set mgr mgr/dashboard/ssl false
sudo microceph.ceph mgr module enable dashboard
sudo echo -n "jonk9ym.;lkj;lkj" | sudo microceph.ceph dashboard ac-user-create -i - admin administrator
