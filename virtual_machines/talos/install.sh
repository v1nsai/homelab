#!/bin/bash

set -e

LIBVIRTD_ARGS="--listen"
cat virtual_machines/talos/libvirtd.conf | sudo tee -a /etc/libvirt/libvirtd.conf

vagrant up --provider=libvirt

