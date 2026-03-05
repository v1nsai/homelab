#!/bin/bash

# set -e

TALOS_VERSION="$1"
AUTO_CONFIRM="$2"

# Check that version is provided and valid
if [ -z "$TALOS_VERSION" ]; then
  echo "Usage: $0 <talos_version>"
  exit 1
fi
VALID_VERSIONS=$(curl -X GET https://factory.talos.dev/versions | jq -r '.[]')
if ! echo "$VALID_VERSIONS" | grep -q "$TALOS_VERSION"; then
  echo "Invalid Talos version: $TALOS_VERSION"
  echo "Valid versions are: $VALID_VERSIONS"
  exit 1
else 
  echo "Upgrading to Talos version: $TALOS_VERSION"
fi

# Generate schematics for extensions
echo "Generating schematics for Talos version $TALOS_VERSION..."
NO_NVIDIA_SCHEMATIC_ID=$(curl -X POST https://factory.talos.dev/schematics \
  -H "Content-Type: application/json" \
  -d '{
    "customization": {
      "systemExtensions": {
        "officialExtensions": [
          "siderolabs/iscsi-tools",
          "siderolabs/util-linux-tools"
        ]
      }
    }
  }' | jq -r '.id')

NVIDIA_SCHEMATIC_ID=$(curl -X POST https://factory.talos.dev/schematics \
  -H "Content-Type: application/json" \
  -d '{
    "customization": {
      "systemExtensions": {
        "officialExtensions": [
          "siderolabs/iscsi-tools",
          "siderolabs/util-linux-tools",
          "siderolabs/nonfree-kmod-nvidia-lts",
          "siderolabs/nvidia-container-toolkit-lts"
        ]
      }
    }
  }' | jq -r '.id')

if [ -z "$NO_NVIDIA_SCHEMATIC_ID" ] || [ -z "$NVIDIA_SCHEMATIC_ID" ]; then
  echo "Failed to generate schematics"
  exit 1
else
  echo -e "Generated schematics: \n\
    NVIDIA_SCHEMATIC_ID=$NVIDIA_SCHEMATIC_ID \n\
    NO_NVIDIA_SCHEMATIC_ID=$NO_NVIDIA_SCHEMATIC_ID \n\
    TALOS_VERSION=$TALOS_VERSION"
fi

# Ask user to confirm before proceeding with upgrade, default to no
if [ "$AUTO_CONFIRM" != "true" ]; then
  read -p "Proceed with upgrade? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Upgrade cancelled"
      exit 1
  fi
fi

# Upgrade nodes
echo "Upgrading bigrig..."
talosctl upgrade \
    --nodes 192.168.1.154 \
    --image "factory.talos.dev/installer/$NVIDIA_SCHEMATIC_ID:$TALOS_VERSION" \
    --wait

echo "Upgrading tiffrig..."
talosctl upgrade \
    --nodes 192.168.1.161 \
    --image "factory.talos.dev/installer/$NO_NVIDIA_SCHEMATIC_ID:$TALOS_VERSION" \
    --wait

echo "Upgrading oppenheimer..."
talosctl upgrade \
    --nodes 192.168.1.152 \
    --image "factory.talos.dev/installer/$NO_NVIDIA_SCHEMATIC_ID:$TALOS_VERSION" \
    --wait
