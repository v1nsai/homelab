#!/bin/bash

set -e

# create docker context
docker context create talos-homelab \
  --description "Remote docker daemon on Talos homelab" \
  --docker "host=tcp://dind.internal:2376,ca=$HOME/.docker/talos-remote/ca.pem,cert=$HOME/.docker/talos-remote/cert.pem,key=$HOME/.docker/talos-remote/key.pem"