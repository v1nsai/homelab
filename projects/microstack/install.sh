#!/bin/bash

set -e

# echo "Installing prerequisites..."
# sudo apt install -y libvirt-daemon-system multipass
# multipass set local.driver=libvirt

# TODO REMOVE THIS TESTING ONLY
multipass delete -p --all
sleep 5

multipass launch \
    --name microstack \
    --cpus 4 \
    --memory 16G \
    --disk 50G \
    --mount /mnt/blackbox:/mnt/blackbox \
    --mount ./projects/microstack/:/home/ubuntu/microstack \
    --network bridged \
    --network "name=bridge1"
# multipass exec microstack -- sudo snap install multipass
multipass shell microstack

echo "Yay hopefully"