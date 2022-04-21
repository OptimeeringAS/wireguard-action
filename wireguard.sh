#!/bin/bash

set -o errexit -o pipefail -o nounset

readonly endpoint=${ENDPOINT}
readonly endpoint_public_key=${PUBLIC_KEY}
readonly peer_id=${PEER_IP}
readonly allowed_ips=${ALLOWED_IPS}
readonly private_key=${PRIVATE_KEY}
readonly preshared_key=${PRESHARED_KEY}

wg_cleanup() {
    unset PRIVATE_KEY
    unset PRESHARED_KEY
    sudo rm -f -- /etc/wireguard/github.conf
}

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends wireguard-tools
trap wg_cleanup EXIT

cat > github.conf <<EOT
[Interface]
PrivateKey = $private_key
Address = $peer_id

[Peer]
PublicKey = $endpoint_public_key
AllowedIPs = $allowed_ips
Endpoint = $endpoint
PersistentKeepalive = 25
EOT

if [ -n "$preshared_key" ]; then
    echo PresharedKey=$preshared_key >> github.conf
fi     

sudo cp github.conf /etc/wireguard

sudo wg-quick up github || exit 1