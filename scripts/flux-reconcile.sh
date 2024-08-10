#!/bin/bash

set -e

flux reconcile source git homelab

LOCATION="$1"
if [ ! -z "$LOCATION" ]; then
    flux reconcile kustomization watch-$LOCATION
fi