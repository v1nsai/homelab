#!/bin/bash

set -e

# if the file /postinstall-has-run exists, then the postinstall script has already run and exit gracefully
if [ -f /postinstall-has-run ]; then
    exit 0
fi

apt update
apt install -y openssh-server vim unminimize sudo nnn git
unminimize

# ssh
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
service ssh restart

# user
adduser --disabled-password --gecos "" $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
cp /authorized_keys /home/$USERNAME/.ssh/authorized_keys
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys

# node 



# If everything runs successfully, don't bother running next startup
touch /postinstall-has-run