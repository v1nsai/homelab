#!/bin/bash

set -e

kubectl apply \
    --namespace irma-nfs \
    --filename cluster/bootstrap/talos/extensions/nfs/server.yaml