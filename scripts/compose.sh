#!/bin/bash

set -e

docker compose -f projects/$1/docker-compose.yml -p $1 $2 $3
