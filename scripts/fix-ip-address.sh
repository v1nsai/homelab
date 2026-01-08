#!/bin/bash

NODE_IP="192.168.1.229"
talosctl -n $NODE_IP -e $NODE_IP patch machineconfig --patch "$(cat <<EOF
machine:
  network:
    interfaces:
      - interface: eno1
        dhcp: false
        addresses:
          - 192.168.1.152/24
        routes:
          - network: 0.0.0.0/0
            gateway: 192.168.1.1
EOF
)"