#!/bin/bash

set -e

# if the file /postinstall-has-run exists, then the postinstall script has already run and exit gracefully
if [ -f /postinstall-has-run ]; then
    exit 0
fi

apt update
apt install -y openssh-server vim unminimize sudo nnn git wget
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

# docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update 

# Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install 18
nvm use 18

# If everything runs successfully, don't bother running next startup
touch /postinstall-has-run