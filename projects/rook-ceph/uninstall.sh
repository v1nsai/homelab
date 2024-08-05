#!/bin/bash

# set -e

# helm delete -n rook-ceph rook-ceph
# helm delete -n rook-cluster rook-ceph-cluster

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

kubectl delete namespace rook-ceph --wait

echo "Wiping ceph OSDs and deleting config files on hosts..."
echo "Wiping bigrig OSDs..."
ssh bigrig /bin/bash << EOF
    DISKS=("/dev/sdb" "/dev/sdc")
    for DISK in "${DISKS[@]}"; do
        sudo sgdisk --zap-all $DISK
        sudo dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
        sudo blkdiscard $DISK
        sudo partprobe $DISK
        sudo rm -rf /var/lib/rook
    done
EOF

echo "Wiping oppenheimer OSDs..."
ssh oppenheimer /bin/bash << EOF
    DISK="/dev/sdb"
    sudo sgdisk --zap-all $DISK
    sudo dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
    sudo blkdiscard $DISK
    sudo partprobe $DISK
    sudo rm -rf /var/lib/rook
EOF

echo "Wiping tiffrig OSDs..."
ssh bigrig /bin/bash << EOF
    DISK="/dev/sda"
    sudo sgdisk --zap-all $DISK
    sudo dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
    # sudo blkdiscard $DISK
    sudo partprobe $DISK
    sudo rm -rf /var/lib/rook
EOF