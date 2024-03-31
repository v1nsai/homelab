#!/bin/bash

set -e

echo "Checking if kompose is installed..."
if ! command -v kompose &> /dev/null
then
    echo "Kompose could not be found. Installing now..."
    curl -L https://github.com/kubernetes/kompose/releases/download/v1.32.0/kompose-linux-amd64 -o kompose
    chmod +x kompose
    sudo mv ./kompose /usr/local/bin/kompose
fi

echo "Generating helm charts from project $1..."
kompose convert \
    --file projects/$1/docker-compose.yaml \
    --out projects/$1/kompose \
    --chart
