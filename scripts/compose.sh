#!/bin/bash

set -e

docker-compose $4 -f projects/$1/docker-compose.yml $2 $3