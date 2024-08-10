#!/bin/bash

set -e

# keeps track of all the extensions installed on each machine

# bigrig
# iscsi-tools util-linux-tools nvidia-container-toolkit nonfree-kmod-nvidia
talosctl upgrade \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170 \
  --image factory.talos.dev/installer/8f8a8d4be4bde03c257e0cac6274c567053a5ed8dfa0a00ce234abef61e5067d:v1.7.5

# tiffrig
# iscsi-tools util-linux-tools 
talosctl upgrade \
  --nodes 192.168.1.155 \
  --endpoints 192.168.1.155 \
  --image factory.talos.dev/installer/613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245:v1.7.4

# oppenheimer
# iscsi-tools util-linux-tools 
talosctl upgrade \
    --nodes 192.168.1.162 \
    --endpoints 192.168.1.162 \
    --image factory.talos.dev/installer/613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245:v1.7.5
