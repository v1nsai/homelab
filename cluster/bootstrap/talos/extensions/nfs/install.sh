#!/bin/bash

set -e

kubectl apply \
    --namespace blueberry-nfs \
    --filename cluster/bootstrap/talos/extensions/nfs/server.yaml