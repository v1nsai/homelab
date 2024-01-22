#!/bin/bash

set -e

servers=( "bigrig" "ASUSan" "oppenheimer" )

for server in "${servers[@]}"; do
    echo "Executing '$@' on '$server'"
    ssh $server "$@"
done
