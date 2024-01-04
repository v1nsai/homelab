#!/bin/bash

set -e
# source projects/microk8s/.env

# Most of this is intended as copy/paste.  Too much of a pain to automate for now.

# Windows
## Run this after setting up master node
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
# sudo microceph cluster add $hostname_of_node

echo "Creating and adding virtual disks to microceph cluster..."
# burn it down first
# sudo snap remove --purge microceph
# sudo snap install microceph
# sudo losetup -d $(sudo losetup | grep "$CEPH_DATA_DIR" | awk '{print $1}')

CEPH_DATA_DIR="/mnt/ceph"
sudo mkdir -p $CEPH_DATA_DIR
for i in {0..4}; do
    # echo "Creating virtual disk $CEPH_DATA_DIR/loop$i..."
    # sudo dd if=/dev/zero of=$CEPH_DATA_DIR/loop$i bs=1M count=10240
    CEPH_LOOP_DISK=$(sudo losetup -f)
    sudo losetup $CEPH_LOOP_DISK $CEPH_DATA_DIR/loop$i
    echo "Adding virtual disk $CEPH_DATA_DIR/loop$i to ceph..."
    sudo microceph disk add --wipe $CEPH_LOOP_DISK
done

# Add external disks here
sudo microceph disk add --wipe /dev/sdc

# Force remove a node that is down
## Delete OSDs
# sudo ceph health detail
# OSD_ID= # Find OSD ID's in the output, eg. osd.1 osd.2
# sudo ceph osd out $OSD_ID
# sudo ceph osd crush remove $OSD_ID
# ceph auth del $OSD_ID
# ceph osd rm $OSD_ID

# # Delete MONs
# MON_ID= # hostname of the node by default
# sudo ceph mon remove $MON_ID
