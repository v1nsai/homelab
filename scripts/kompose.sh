#!/bin/bash

set -e 

echo "Generating helm charts from project $1..."
kompose convert \
    --file projects/$1/docker-compose.yaml \
    --out projects/$1/kompose \
    --chart
