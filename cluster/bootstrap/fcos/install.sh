#!/bin/bash

set -e

# Convert butane configs to ignition
for FILE in cluster/bootstrap/coreos/butane/*.yaml; do
  FILE=$(basename ${FILE})
  butane cluster/bootstrap/coreos/butane/${FILE} \
    --strict \
    --pretty \
    --output cluster/bootstrap/coreos/ignition/${FILE%.*}.json
done

# configure FLUO for auto reboots
kubectl apply -k https://github.com/flatcar/flatcar-linux-update-operator/tree/030e43574c229eeb5a8858f03bdcc997f38131d9/examples/deploy --dry-run=client -o yaml

# Create installer iso
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
  iso customize \
    --dest-ignition /data/ignition/generic.json \
    --dest-console ttyS0,115200n8 \
    --dest-console tty0 \
    --output /Downloads/fcos-generic.iso \
    /Downloads/fedora-coreos-40.20240808.3.0-live.x86_64.iso
