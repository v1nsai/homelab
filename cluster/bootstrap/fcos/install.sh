#!/bin/bash

set -e

# Generate password hash
cat cluster/bootstrap/fcos/password.env | docker run --interactive --rm quay.io/coreos/mkpasswd --stdin --method=yescrypt

# Convert butane configs to ignition
for FILE in cluster/bootstrap/fcos/butane/*.yaml; do
  FILE=$(basename ${FILE})
  butane cluster/bootstrap/fcos/butane/${FILE} \
    --strict \
    --pretty \
    --output cluster/bootstrap/fcos/ignition/${FILE%.*}.json
done

# push changes to github
# git add cluster/bootstrap/fcos
# git commit -m "updating remote fcos ignition configs"
# git push

# Download Fedora CoreOS image
# docker run \
#   --security-opt label=disable \
#   --pull=always \
#   --rm \
#   --volume ~/Downloads:/Downloads \
#   --workdir /Downloads \
#   quay.io/coreos/coreos-installer:release download -s stable -p metal -f iso -a x86_64

IMAGE_NAME=$(ls ~/Downloads | grep fedora-coreos | grep -v \.sig)

# Create SSH only iso
# rm -rf ~/Downloads/fcos-ssh-only.iso
# docker run \
#   --pull=always \
#   --privileged \
#   --rm \
#   --volume /dev:/dev \
#   --volume /run/udev:/run/udev \
#   --volume ~/Downloads:/Downloads \
#   --volume ./cluster/bootstrap/fcos:/data \
#   --workdir /data \
#   quay.io/coreos/coreos-installer:release \
#   iso ignition embed \
#     --ignition-file /data/ignition/node-remote.json \
#     --output /Downloads/fcos-ssh-only.iso \
#     /Downloads/${IMAGE_NAME}

# Create fully auto installer iso for all install devices
BOOT_DEVICES=(/dev/sda /dev/nvme0n1)
for BOOT_DEVICE in ${BOOT_DEVICES[@]}; do
  export BOOT_DEVICE
  rm -rf ~/Downloads/"fcos-$(basename $BOOT_DEVICE)-auto-installer.iso"
  envsubst < cluster/bootstrap/fcos/installer-config.yaml > /tmp/installer-config.yaml
  docker run \
    --pull=always \
    --privileged \
    --rm \
    --volume /dev:/dev \
    --volume /run/udev:/run/udev \
    --volume ~/Downloads:/Downloads \
    --volume /tmp:/tmp \
    quay.io/coreos/coreos-installer:release \
    iso customize \
      --installer-config /tmp/installer-config.yaml \
      --output /Downloads/"fcos-$(basename $BOOT_DEVICE)-auto-installer.iso" \
      /Downloads/${IMAGE_NAME}
done

# SSH into node
# coreos-installer install \
#   --ignition-url https://raw.githubusercontent.com/v1nsai/homelab/develop/cluster/bootstrap/fcos/ignition/node.json \
#   /dev/sda