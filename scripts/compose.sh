#!/bin/bash

set -e

docker compose -f projects/$1/docker-compose.yaml -p ${@}
