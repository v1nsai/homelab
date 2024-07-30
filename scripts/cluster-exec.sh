#!/bin/bash

# set -e

servers=( "bigrig" "tiffrig" "oppenheimer" )

for server in "${servers[@]}"; do
    echo "Executing '$@' on '$server'"
    ssh $server "$@"
done
