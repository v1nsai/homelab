#!/bin/bash

cd /opt/deploy
# COMPOSE_PROJECT_NAME=

install() {
    echo "Configuring SSL..."
    if [[ -z "$URL" ]]; then
        echo "URL variable not set, defaulting to self-signed certificate..."
        return 1
    fi
    URL=$(echo $URL | sed 's/https\?:\/\///g') # strip http(s):// from URL    
    docker compose down traefik # in case this isn't the first reboot
    yq eval '.http.routers.whoami.tls.certResolver = "letsencrypt-prod"' -i /opt/deploy/routes.yaml
    docker compose up -d
}

install-self-signed() {
    echo "Creating a self-signed certificate..."
    URL=$(curl -s ifconfig.io)
    docker compose down traefik
    yq eval '.http.routers.whoami.tls = {}' -i /opt/deploy/routes.yaml
    docker compose up -d
}

cleanup() {
    echo "Checking health status of containers..."
    sleep 30
    for container in "nextcloud-aio-mastercontainer" "traefik"; do
        healthcheck $container
    done
    sudo crontab -r
    echo "Deleting install files..."
    cd
    rm -rf /opt/deploy
    echo "Finished cleanup"
}

healthcheck() {
    echo "Checking health status of container $1..."
    while [[ $(docker inspect -f '{{.State.Health.Status}}' $1) == "starting" ]]; do
        echo "Container $1 is still starting..."
        sleep 10
    done
    if [[ $(docker inspect -f '{{.State.Health.Status}}' $1) == "healthy" ]]; then
        echo "Container $1 is healthy"
        return 0
    else
        echo "Container $1 is not healthy"
        return 1
    fi
}

echo "Installing dependencies..."
wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
install || install-self-signed
if [[ $? -eq 0 ]]; then
    post-install
    cleanup
else
    install-self-signed
    post-install
fi

