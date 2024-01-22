#!/bin/bash

set -e

sudo apt install -y haproxy keepalived

servers=( "bigrig" "ASUSan" "oppenheimer" )

echo "Installing keepalived and haproxy on all servers..."
scripts/cluster-exec.sh sudo apt install -y haproxy keepalived

for server in "${servers[@]}"; do
    echo "Configuring keepalived for $server..."
    if [[ $server == "oppenheimer" ]]; then
        sed -i 's/state [A-Z]*/state MASTER/g' projects/k3s/keepalived.conf
        sed -i 's/priority [0-9]*/priority 200/g' projects/k3s/keepalived.conf
    else
        sed -i 's/state [A-Z]*/state BACKUP/g' projects/k3s/keepalived.conf
        sed -i 's/priority [0-9]*/priority 100/g' projects/k3s/keepalived.conf
    fi
    scp projects/k3s/haproxy.cfg $server:/home/doctor_ew/haproxy.cfg
    scp projects/k3s/keepalived.conf $server:/home/doctor_ew/keepalived.conf
done

echo "Restarting keepalived and haproxy on all servers..."
scripts/cluster-exec.sh sudo mv /home/doctor_ew/haproxy.cfg /etc/haproxy/haproxy.cfg
scripts/cluster-exec.sh sudo mv /home/doctor_ew/keepalived.conf /etc/keepalived/keepalived.conf
scripts/cluster-exec.sh sudo systemctl restart haproxy
scripts/cluster-exec.sh sudo systemctl restart keepalived
