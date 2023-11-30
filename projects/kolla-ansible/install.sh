#!/bin/bash

set -e

printf "\nSetting up local environment...\n\n"
# sudo apt update
# sudo apt install -y nnn vim python3-dev python3-dev python3-venv net-tools
python3 -m venv ./projects/kolla-ansible/.venv
source ./projects/kolla-ansible/.venv/bin/activate
pip install -U pip
pip install 'ansible-core>=2.14,<2.16'

printf "\nInstalling kolla-ansible and dependencies...\n\n"
pip install git+https://opendev.org/openstack/kolla-ansible@master
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r ./projects/kolla-ansible/.venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ./projects/kolla-ansible/.venv/share/kolla-ansible/ansible/inventory/all-in-one ./projects/kolla-ansible/all-in-one
kolla-ansible install-deps

printf "\nConfiguring kolla-ansible...\n\n"
kolla-genpwd
sed -i 's/#network_interface: "eth0"/network_interface: "eno1"/g' /etc/kolla/globals.yml
sed -i 's/#neutron_external_interface: "eth1"/neutron_external_interface: "enx7cc2c6487c34"/g' /etc/kolla/globals.yml
sed -i 's/#kolla_internal_vip_address: "10.10.10.254"/kolla_internal_vip_address: "192.168.1.2"/g' /etc/kolla/globals.yml
# echo 'enable_*: "yes"' | tee -a /etc/kolla/globals.yml

printf "\nDeploying OpenStack...\n\n"
kolla-ansible -i ./projects/kolla-ansible/all-in-one bootstrap-servers
kolla-ansible -i ./projects/kolla-ansible/all-in-one prechecks
kolla-ansible -i ./projects/kolla-ansible/all-in-one deploy

sleep 10
ping -c 1 192.168.1.1
if [ ! $? -eq 0 ]; then
    echo "Oh shit bail bail BAIL!"
    kolla-ansible destroy -i ./projects/kolla-ansible/all-in-one
fi
