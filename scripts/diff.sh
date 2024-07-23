#!/bin/bash

set -e

VALUES_DEFAULT=$1
VALUES=$2

if [ VALUES == *"helmrelease.yaml" ]; then
    echo "Retrieving values from helmrelease file"
    cat $VALUES | yq '.spec.values' > /tmp/values.yaml
    VALUES="/tmp/values.yaml"
fi

deep diff \
    --ignore-order \
    --ignore-string-type-changes \
    --ignore-numeric-type-changes \
    --ignore-type-subclasses \
    --ignore-string-case \
    --ignore-nan-inequality \
    $VALUES_DEFAULT $VALUES