#!/bin/bash

set -e

echo "fs.inotify.max_user_instances=8192" | sudo tee -a /etc/sysctl.conf
echo "fs.inotify.max_user_watches=655360" | sudo tee -a /etc/sysctl.conf

sudo sysctl -p

# Prevent multipath from getting in the way of longhorn devices
cat <<EOF | sudo tee -a /etc/multipath.conf
blacklist {
    devnode "^sd[a-z0-9]+"
}
EOF
sudo systemctl restart multipathd