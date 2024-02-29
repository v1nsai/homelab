# Install the palworld server
adduser pwserver
sudo su - pwserver
curl -Lo linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh pwserver
./pwserver install

# Interact with the server
docker exec -itu linuxgsm pwserver ./pwserver
## or
alias pwserver='docker exec -itu linuxgsm pwserver ./pwserver'
## or if the docker server won't work at all
alias pwserver='sudo -u pwserver /home/pwserver/pwserver'