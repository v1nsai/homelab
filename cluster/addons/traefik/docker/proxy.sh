#!/bin/bash

cd /opt/deploy

install() {
    echo "Configuring SSL..."
    if [[ -z "$URL" ]]; then
        echo "URL variable not set, defaulting to self-signed certificate..."
        return 1
    fi
    URL=$(echo $URL | sed 's/https\?:\/\///g') # strip http(s):// from URL
    echo $URL    
    docker compose down traefik # in case this isn't the first reboot
    yq eval '.http.routers.router.tls.certResolver = '"$CERTSRESOLVER" -i /etc/traefik/routes.yaml
    docker compose up -d
}

install-self-signed() {
    echo "Configuring self-signed certificate..."
    URL=$(curl -s ifconfig.io)
    mkdir -p /etc/traefik/ssl
    docker compose down traefik
    yq eval '.http.routers.router.tls = {}' -i /etc/traefik/routes.yaml
    docker compose up -d
}

cleanup() {
    echo "Checking health status of containers..."
    for container in $HEALTHCHECK_CONTAINERS ; do
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
        exit 1
    fi
}

pre-install() {
    echo "Installing dependencies..."
    wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
    mkdir -p /etc/traefik
    touch /etc/traefik/acme.json
    chmod 600 /etc/traefik/acme.json
}

pre-install -e || (echo "Failed to install dependencies, exiting..." && exit 1)
install -e && cleanup || (echo "Failed to install, exiting...") # install-self-signed -e ||
install-self-signed -e || (echo "Failed to install self-signed certificate, exiting..." && exit 1)
# post-install -e || (echo "Failed to configure trusted proxies, exiting..." && exit 1)
# cleanup -e || (echo "Failed to cleanup, exiting..." && exit 1)
