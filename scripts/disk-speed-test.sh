#!/bin/bash

# write speed test
dd if=/dev/zero of=./test.img bs=1M count=1024 conv=fdatasync

# clear the buffers
sudo sh -c "/usr/bin/echo 3 > /proc/sys/vm/drop_caches"

# read speed test
dd if=./test.img of=/dev/null bs=1M count=1024
