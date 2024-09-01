#!/bin/bash

set -e

# Convert butane configs to ignition
HOSTS=(bigrig oppenheimer tiffrig)
for HOST in "${HOSTS[@]}"; do
  butane cluster/bootstrap/flatcar/butane/${HOST}.yaml \
    --strict \
    --pretty \
    --output cluster/bootstrap/flatcar/ignition/${HOST}.json
done

# kernel params
# env.HOSTNAME=bigrig ignition.config.url=

# configure FLUO for auto reboots
kubectl apply -k https://github.com/flatcar/flatcar-linux-update-operator/tree/030e43574c229eeb5a8858f03bdcc997f38131d9/examples/deploy --dry-run=client -o yaml

