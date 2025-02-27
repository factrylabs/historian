#!/bin/bash

# User data script for launching Factry Historian with a custom cloud-init configuration for Ubuntu 24.04 LTS

# Update system
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
sudo -E apt-get -qy update
sudo -E apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
sudo -E apt-get -qy autoclean

# Add Docker's official GPG key:
sudo apt-get update -yq
sudo apt-get install -yq ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt-get update -yq

# Install Docker CE
sudo apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin caddy

# Get fqdn from cloud-init
export FQDN=$(hostname -f)
export GF_SERVER_ROOT_URL="https://${FQDN}/grafana"

# Generate passwords
export DB_PASSWORD=$(openssl rand -base64 32 | cut -c1-16)
export INFLUXDB_ADMIN_PASSWORD=$(openssl rand -base64 32 | cut -c1-16)
export GF_SECURITY_ADMIN_PASSWORD=$(openssl rand -base64 32 | cut -c1-16)

# Write passwords to credentials file
cat <<EOF | sudo tee ~/historian-credentials
DB_PASSWORD=${DB_PASSWORD}
INFLUXDB_ADMIN_PASSWORD=${INFLUXDB_ADMIN_PASSWORD}
GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD}
EOF

chmod 600 ~/historian-credentials

# Set environment variables
export GF_BIND_ADDRESS="127.0.0.1"
export RESET_BIND_ADDRESS="127.0.0.1"

# Write caddy config
cat <<EOF | sudo tee /etc/caddy/Caddyfile
https://${FQDN} {
    reverse_proxy localhost:8000

    reverse_proxy /grafana/* localhost:3000 {
        header_up Host {http.reverse_proxy.upstream.hostport}
        header_up X-Real-IP {http.request.remote}
        header_up X-Forwarded-For {http.request.remote}
        header_up X-Forwarded-Port {http.request.port}
        header_up X-Forwarded-Proto {http.request.scheme}
    }
}
EOF

sudo systemctl restart caddy

cd ~/ || exit

curl -sSL https://raw.githubusercontent.com/factrylabs/historian/refs/heads/main/advanced/docker-compose.yml -o docker-compose.yml

# Start services
sudo -E docker compose -p historian up -d
