#!/bin/bash

set -e

# if projects/monitoring/.env not found create it
if [ ! -f projects/monitoring/.env ]; then
    echo "Creating new .env file in projects/monitoring..."
    echo "Enter comma separated list of hosts to monitor with blackbox ie https://host1,https://host2"
    read -r hosts
    echo "BLACKBOX_TARGETS=$hosts" > projects/monitoring/.env
fi
source projects/monitoring/.env

# split into an array, replace the first host with the first element then add the others
IFS=',' read -r -a $hosts <<< "$BLACKBOX_TARGETS"
yq -i eval '.scrape_configs[] | select(.job_name == "blackbox") | .static_configs[0].targets[0] = ["'${hosts[0]}'"]' projects/monitoring/prometheus.yml
hosts=("${hosts[@]:1}")
for host in "${hosts[@]}"; do
    yq -i eval '.scrape_configs[] | select(.job_name == "blackbox") | .static_configs[0].targets += ["'$host'"]' projects/monitoring/prometheus.yml
done