#!/bin/bash

set -e

CHART=false
for i in "$@"; do
    case $i in
        --chart)
            CHART=true
            shift
            ;;
        *)
            PROJECT=$i
        ;;
    esac
done

echo "Checking if kompose is installed..."
if ! command -v kompose &> /dev/null
then
    echo "Kompose could not be found. Installing now..."
    curl -L https://github.com/kubernetes/kompose/releases/download/v1.32.0/kompose-linux-amd64 -o kompose
    chmod +x kompose
    sudo mv ./kompose /usr/local/bin/kompose
fi

echo "Checking if helmify is installed..."
if ! command -v helmify &> /dev/null; then
    echo "Helmify could not be found. Installing now..."
    URL=$(curl -s -L -I -o /dev/null -w '%{url_effective} https://github.com/arttor/helmify/releases/latest')
    URL="$URL/helmify_Linux_x86_64.tar.gz"
    curl -O $URL
    sudo tar -xvf helmify_Linux_x86_64.tar.gz /usr/bin/helmify
    sudo chmod +x /usr/bin/helmify
fi

echo "Generating kube manifests from project $PROJECT..."
kompose convert \
    --file projects/$PROJECT/docker-compose.yaml \
    --out projects/$PROJECT/kompose.yaml

if $CHART; then
    echo "Converting kube manifests to helm chart..."
    cat projects/$PROJECT/kompose | helmify projects/$PROJECT/helmify -cert-manager-as-subchart
fi