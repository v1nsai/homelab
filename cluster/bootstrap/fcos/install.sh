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

# configure FLUO for auto reboots
# kubectl apply -k https://github.com/flatcar/flatcar-linux-update-operator/tree/030e43574c229eeb5a8858f03bdcc997f38131d9/examples/deploy --dry-run=client -o yaml

# Create installer iso
rm -rf ~/Downloads/fcos-generic.iso
docker run \
  --pull=always \
  --privileged \
  --rm \
  --volume /dev:/dev \
  --volume /run/udev:/run/udev \
  --volume ~/Downloads:/Downloads \
  --volume ./cluster/bootstrap/fcos:/data \
  --workdir /data \
  quay.io/coreos/coreos-installer:release \
  iso ignition embed \
    --ignition-file /data/ignition/node-remote.json \
    --output /Downloads/fcos-generic.iso \
    /Downloads/fedora-coreos-40.20240808.3.0-live.x86_64.iso
