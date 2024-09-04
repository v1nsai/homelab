#!/bin/bash

set -e

LIBVIRTD_ARGS="--listen"
# virsh list | awk '{print $2}' | xargs -t -L1 virsh domifaddr

# cat virtual_machines/talos/libvirtd.conf | sudo tee -a /etc/libvirt/libvirtd.conf
# sudo systemctl restart libvirtd

volumes=( talos_control-plane-node-1-vda.raw talos_control-plane-node-2-vda.raw talos_control-plane-node-3-vda.raw )
for volume in "${volumes[@]}"; do
  echo "Deleting volume $volume"
  virsh vol-delete --pool default $volume
done

cd virtual_machines/talos
vagrant up || true
cd ~/homelab