#!/bin/bash

set -e

sudo snap install openstack
sunbeam prepare-node-script | bash -x && newgrp snap_daemon
# sudo usermod -aG snap_daemon ubuntu
envsubst '$USER_PASSWORD' < projects/microstack/preseed.yaml.template > projects/microstack/preseed.yaml
sunbeam cluster bootstrap -p projects/microstack/preseed.yaml
sunbeam configure -p projects/microstack/preseed.yaml --openrc projects/microstack/microstack.env
sunbeam dashboard-url
# sunbeam launch ubuntu -n test
