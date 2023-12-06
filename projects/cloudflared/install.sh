#!/bin/bash

set -e
CLOUDFLARE_TOKEN=
source projects/cloudflared/cloudflare_token.secret.env

envsubst < projects/cloudflared/docker-compose.yml.template > projects/cloudflared/docker-compose.yml
docker compose -f projects/cloudflared/docker-compose.yml up -d
docker logs -f cloudflared
