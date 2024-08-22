#!/bin/bash

set -e

# convert docker compose file into k8s yaml with kompose
kompose convert -f apps/services/jellyseerr/docker-compose.yaml -o apps/services/jellyseerr/app/
