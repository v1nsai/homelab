#!/bin/bash

set -e
source apps/services/torrents/.env

kubectl create secret generic wireguard-config \
    --namespace torrents \
    --from-file=apps/services/torrents/secrets/gluetun/wg0.conf \
    --dry-run=client \
    -o yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > apps/services/torrents/app/wireguard-config-sealed.yaml

# Generate stremio .htpasswd file
PASSWD=$(openssl rand -base64 20)
# Create .htpasswd file with the first element from the USERS array
echo "User: ${USERS[0]} Password: $PASSWD"
htpasswd -c -B -b apps/services/torrents/stremio.htpasswd "${USERS[0]}" "$PASSWD"
for USER in "${USERS[@]:1}"; do
    PASSWD=$(openssl rand -base64 20)
    echo "User: $USER Password: $PASSWD"
    htpasswd -B -b apps/services/torrents/stremio.htpasswd "$USER" "$PASSWD"
done

kubectl create secret generic stremio-htpasswd \
    --namespace torrents \
    --from-file=htpasswd=apps/services/torrents/stremio.htpasswd \
    --dry-run=client \
    -o yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > apps/services/torrents/app/stremio-htpasswd-sealed.yaml