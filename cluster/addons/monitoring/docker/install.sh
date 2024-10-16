#!/bin/bash

set -e

# if cluster/addons/monitoring/.env not found create it
if [ ! -f cluster/addons/monitoring/.env ]; then
    echo "Creating new .env file in cluster/addons/monitoring..."
    echo "Enter comma separated list of hosts to monitor with blackbox ie https://host1,https://host2"
    read -r hosts
    echo "BLACKBOX_TARGETS=$hosts" > cluster/addons/monitoring/.env
fi
source cluster/addons/monitoring/.env

# split into an array, replace the first host with the first element then add the others
IFS=',' read -r -a $hosts <<< "$BLACKBOX_TARGETS"
yq -i eval '.scrape_configs[] | select(.job_name == "blackbox") | .static_configs[0].targets[0] = ["'${hosts[0]}'"]' cluster/addons/monitoring/prometheus.yml
hosts=("${hosts[@]:1}")
for host in "${hosts[@]}"; do
    yq -i eval '.scrape_configs[] | select(.job_name == "blackbox") | .static_configs[0].targets += ["'$host'"]' cluster/addons/monitoring/prometheus.yml
done