#!/bin/bash

set -e

helm delete -n rook-ceph rook-ceph || true
helm delete -n rook-cluster rook-ceph-cluster || true
kubectl delete namespace rook-ceph &

echo "Removing CRs and CRDs..."
kubectl -n rook-ceph patch cephcluster rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'
kubectl -n rook-ceph delete cephcluster rook-ceph
for CRD in $(kubectl get crd -n rook-ceph | awk '/ceph.rook.io/ {print $1}'); do
    kubectl get -n rook-ceph "$CRD" -o name | \
    xargs -I {} kubectl patch -n rook-ceph {} --type merge -p '{"metadata":{"finalizers": []}}'
done

echo "Removing finalizers and adding delete annotations..."
kubectl -n rook-ceph patch configmap rook-ceph-mon-endpoints --type merge -p '{"metadata":{"finalizers": []}}'
kubectl -n rook-ceph patch secrets rook-ceph-mon --type merge -p '{"metadata":{"finalizers": []}}'
# kubectl -n rook-ceph annotate cephfilesystemsubvolumegroups.ceph.rook.io my-subvolumegroup rook.io/force-deletion="true"
# kubectl -n rook-ceph delete cephfilesystemsubvolumegroups.ceph.rook.io my-subvolumegroup

echo "Waiting for namespace to be deleted..."
while kubectl get namespace rook-ceph &> /dev/null; do
    echo "Namespace still exists, waiting 5s and trying again..."
    sleep 5
done

echo "Wiping ceph OSDs and deleting config files on hosts..."
echo "Wiping bigrig OSDs..."
DISK="/dev/sdb"
sudo sgdisk --zap-all $DISK
sudo dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
sudo blkdiscard $DISK
sudo partprobe $DISK

sudo rm -rf /var/lib/rook

echo "Wiping oppenheimer OSDs..."
ssh oppenheimer /bin/bash << EOF
    DISK="/dev/sdc"
    sudo sgdisk --zap-all $DISK
    sudo dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
    sudo blkdiscard $DISK
    sudo partprobe $DISK
    sudo rm -rf /var/lib/rook
EOF

echo "Wiping tiffrig OSDs..."
ssh tiffrig /bin/bash << EOF
    sudo rm -rf /var/lib/rook
EOF