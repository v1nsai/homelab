#!/bin/bash

set -e

talosctl patch machineconfig \
    --endpoints 192.168.1.133 \
    --nodes 192.168.1.162,192.168.1.155,192.168.1.170 \
    --patch-file projects/talos/extensions/longhorn/patch.yaml