#!/bin/bash

# sudo cp scripts/talosctlwrapper.sh /usr/local/bin/talosctlwrapper

set -e

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--target)
      TARGET="$2"
      shift
      shift
      ;;
    bigrig)
      TARGET="192.168.1.170"
      shift
      ;;
    tiffrig)
      TARGET="192.168.1.155"
      shift
      ;;
    oppenheimer)
      TARGET="192.168.1.162"
      shift
      ;;
    asusan)
      TARGET="192.168.1.186"
      shift
      ;;
    all)
      TARGET="192.168.1.162,192.168.1.155,192.168.1.170"
      shift
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift
      ;;
  esac
done

# Prevent upgrading without the --preserve flag due to using localpath storage
for i in "${POSITIONAL_ARGS[@]}"; do
  if [[ $i == "upgrade" ]]; then
    POSITIONAL_ARGS+=("--preserve")
  fi
done

talosctl \
  --nodes $TARGET \
  --endpoints 192.168.1.133 \
  "${POSITIONAL_ARGS[@]}"