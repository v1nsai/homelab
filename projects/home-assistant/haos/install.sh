#!/bin/bash

set -e

virt-install \
    --name hass \
    --description "Home Assistant OS" \
    --os-variant=generic \
    --ram=2048 \
    --vcpus=2 \
    --disk /home/doctor_ew/haos_ova-12.1.qcow2,bus=sata \
    --import \
    --graphics none \
    --boot uefi