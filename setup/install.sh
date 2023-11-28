#!/bin/bash

set -e

echo ""
echo "Setting up local environment..."
echo ""
sudo apt update
sudo apt install -y docker docker-compose docker-compose-v2 nnn vim python3-dev python3-dev python3-venv libffi-dev gcc libssl-dev net-tools
python3 -m venv setup/.venv
source ./setup/.venv/bin/activate
pip install -U pip
pip install 'ansible-core>=2.14,<2.16'

echo ""
echo "Installing kolla-ansible and dependencies..."
echo ""
pip install git+https://opendev.org/openstack/kolla-ansible@master
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r ./setup/.venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ./setup/.venv/share/kolla-ansible/ansible/inventory/all-in-one ./setup/all-in-one
kolla-ansible install-deps

echo ""
echo "Configuring kolla-ansible..."
echo ""
kolla-genpwd
sed -i 's/#openstack_tag_suffix: ""/openstack_tag_suffix: "x86-64"/g' /etc/kolla/globals.yml
sed -i 's/#network_interface: "eth0"/network_interface: "eno1"/g' /etc/kolla/globals.yml
sed -i 's/#neutron_external_interface: "eth1"/neutron_external_interface: "enx7cc2c6487c34"/g' /etc/kolla/globals.yml
sed -i 's/#kolla_internal_vip_address: "10.10.10.254"/kolla_internal_vip_address: "192.168.1.2"/g' /etc/kolla/globals.yml
echo 'enable_*: "yes"' | tee -a /etc/kolla/globals.yml

echo ""
echo "Deploying OpenStack..."
echo ""
kolla-ansible -i ./setup/all-in-one bootstrap-servers
kolla-ansible -i ./setup/all-in-one prechecks
kolla-ansible -i ./setup/all-in-one deploy
