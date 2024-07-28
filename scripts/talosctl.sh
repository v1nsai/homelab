#!/bin/bash

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
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift
      ;;
  esac
done

talosctl \
    --nodes $TARGET \
    --endpoints $TARGET \
    "${POSITIONAL_ARGS[@]}"