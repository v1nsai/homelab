#!/bin/bash

set -e

# Download project
# wget https://github.com/vulhub/vulhub/archive/master.zip -O projects/vulhub/vulhub-master.zip
# unzip projects/vulhub/vulhub-master.zip -d projects/vulhub/

# Compile environment
docker compose -f projects/vulhub/vulhub-master/flask/ssti/docker-compose.yml build

# Run environment
docker compose -f projects/vulhub/vulhub-master/flask/ssti/docker-compose.yml up -d