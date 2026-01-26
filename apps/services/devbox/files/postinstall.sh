#!/bin/bash

set -e

# if the file /postinstall-has-run exists, then the postinstall script has already run and exit gracefully
if [ -f /postinstall-has-run ]; then
    echo "Postinstall script has already run, skipping..."
    exit 0
fi

echo "Installing packages..."
apt update
apt install -y openssh-server build-essential vim unminimize sudo nnn git wget jq curl net-tools unzip zip 
echo -e "y\n" | unminimize

echo "Configuring SSH..."
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
service ssh restart

echo "Configuring user..."
adduser --disabled-password --gecos "" $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
mkdir -p /home/$USERNAME/.ssh
cp /root/.ssh/authorized_keys /home/$USERNAME/.ssh/authorized_keys
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys

echo "Installing Docker..."
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
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker $USERNAME
sudo service docker restart

echo "Installing Node..."
su - $USERNAME -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
# cat <<EOF >> /home/$USERNAME/.bashrc
# export NVM_DIR="/home/$USERNAME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# EOF
# source /home/$USERNAME/.bashrc
# nvm install 18
# nvm use 18

# If everything runs successfully, don't bother running next startup
touch /postinstall-has-run
