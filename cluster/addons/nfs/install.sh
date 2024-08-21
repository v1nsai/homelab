#!/bin/bash

sudo apt install -y nfs-kernel-server nfs-common apparmor-profiles
sudo systemctl enable nfs-kernel-server

echo "/mnt/data *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
echo "/mnt/irma/longhorn *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
sudo exportfs -a

sudo systemctl restart nfs-kernel-server