#!/bin/bash

set -e
# source projects/microk8s/.env

# Windows
## Run this after setting up master node.  Don't use windows node for master.  Just....don't.
winget install multipass --classic
multipass delete --purge $WINDOWS_NODE_NAME
WINDOWS_NODE_NAME=""
multipass launch  --name ${WINDOWS_NODE_NAME}  --cpus 4  --memory 16G  --disk 20G  --network bridged --mount C:/Users/doctor_ew/multipass/${WINDOWS_NODE_NAME}:/mnt/${WINDOWS_NODE_NAME}
multipass shell ${WINDOWS_NODE_NAME}
sudo snap install microceph
sudo microceph init
# set the interface to use the bridged one, everything else default except no to adding disks
# Follow linux instructions next

# Linux
## Use for master node
echo "Setting up microceph..."
sudo snap install microceph
# sudo snap refresh --hold microceph # hold updates
# only run on master node
# sudo microceph cluster bootstrap

echo "Creating and adding virtual disks to microceph cluster..."
CEPH_DATA_DIR="/mnt/ceph"
sudo mkdir -p $CEPH_DATA_DIR
for i in {0..4}; do
    echo "Creating virtual disk $CEPH_DATA_DIR/loop$i..."
    sudo dd if=/dev/zero of=$CEPH_DATA_DIR/loop$i bs=1M count=10240
    CEPH_LOOP_DISK=$(sudo losetup -f)
    sudo losetup $CEPH_LOOP_DISK $CEPH_DATA_DIR/loop$i
    echo "Adding virtual disk $CEPH_DATA_DIR/loop$i to ceph..."
    sudo microceph disk add --wipe $CEPH_LOOP_DISK
done

# Add external disks here
# sudo microceph disk add --wipe /dev/sdc

# Too lazy to figure out why microceph times out when trying to remove nodes that are down
# CEPH_DATA_DIR="/mnt/ceph"
# CEPH_LOOP_DISKS=$(sudo losetup -a | grep "$CEPH_DATA_DIR" | awk '{print $1}' | tr -d ":")
# echo $CEPH_LOOP_DISKS
# for CEPH_LOOP_DISK in $CEPH_LOOP_DISKS; do
#     echo "Adding virtual disk $CEPH_LOOP_DISK to ceph..."
#     sudo microceph disk add --wipe $CEPH_LOOP_DISK
# done

# echo "Adding nodes..."
# sudo microceph cluster add bigrig
# sudo microceph cluster add asusan