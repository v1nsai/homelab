#!/bin/bash

set -e

if ip a | grep -q '192.168.1.170'; then
    echo "bigrig" > /etc/hostname
fi
if ip a | grep -q '192.168.1.155'; then
    echo "tiffrig" > /etc/hostname
fi
if ip a | grep -q '192.168.1.162'; then
    echo "oppenheimer" > /etc/hostname
fi
if ip a | grep -q '192.168.1.211'; then
    echo "testy-boi" > /etc/hostname
fi

touch /etc/test-pre-install-has-run