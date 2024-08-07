#!/bin/bash

set -e

# bigrig
kubectl label node bigrig node.longhorn.io/create-default-disk=config
kubectl annotate node bigrig node.longhorn.io/default-disks-config='
  [
      { 
          "path": "/var/mnt/disk0",
          "allowScheduling": true
      }
  ]
'

# tiffrig
kubectl label node tiffrig node.longhorn.io/create-default-disk=config
kubectl annotate node tiffrig node.longhorn.io/default-disks-config='
  [
      { 
          "path": "/var/mnt/disk0",
          "allowScheduling": true
      }
  ]
'

# oppenheimer
kubectl label node oppenheimer node.longhorn.io/create-default-disk=config
kubectl annotate node oppenheimer node.longhorn.io/default-disks-config='
  [
      { 
          "path": "/var/mnt/disk0",
          "allowScheduling": true
      }
  ]
'
