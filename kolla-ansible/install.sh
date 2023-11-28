#!/bin/bash

set -e

# Configure venv
sudo apt update
sudo apt install -y docker docker-compose docker-compose-v2 nnn vim python3-dev python3-dev python3-venv libffi-dev gcc libssl-dev
python3 -m venv kolla-ansible/.venv
source kolla-ansible/.venv/bin/activate
pip install -U pip
pip install 'ansible-core>=2.14,<2.16'

# Install kolla-ansible and dependencies
pip install git+https://opendev.org/openstack/kolla-ansible@master
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r kolla-ansible/.venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp kolla-ansible/.venv/share/kolla-ansible/ansible/inventory/all-in-one ./kolla-ansible/all-in-one
kolla-ansible install-deps

# Configure kolla-ansible
kolla-ansible genpwd
sed -i 's/#openstack_tag_suffix: ""/openstack_tag_suffix: "x86-64"/g' /etc/kolla/globals.yml
sed -i 's/#network_interface: "eth0"/network_interface: "eno1"/g' /etc/kolla/globals.yml
sed -i 's/#neutron_external_interface: "eth1"/neutron_external_interface: "enx7cc2c6487c34"/g' /etc/kolla/globals.yml
sed -i 's/#kolla_internal_vip_address: "10.10.10.254"/kolla_internal_vip_address: "192.168.1.2"/g' /etc/kolla/globals.yml
echo 'enable_*: "yes"' | tee -a /etc/kolla/globals.yml

# Deploy OpenStack
kolla-ansible -i ./kolla-ansible/all-in-one bootstrap-servers
kolla-ansible -i ./kolla-ansible/all-in-one prechecks
kolla-ansible -i ./kolla-ansible/all-in-one deploy

