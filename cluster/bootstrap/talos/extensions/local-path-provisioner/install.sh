#!/bin/bash

# patch all machines
talosctl patch machineconfig \
  --nodes 192.168.1.170,192.168.1.155,192.168.1.162 \
  --endpoints 192.168.1.133 \
  --patch-file cluster/bootstrap/talos/extensions/local-path-provisioner/patch.yaml
