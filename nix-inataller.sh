#!/bin/bash

set -e

echo "[INFO] Starting Nix installation with SSL certificate setup..."

# Download Mozilla certificate bundle
echo "[INFO] Downloading Mozilla certificate bundle..."
curl -o /tmp/cacert.pem https://curl.se/ca/cacert.pem
sudo mv /tmp/cacert.pem /etc/ssl/cert.pem
sudo chmod 644 /etc/ssl/cert.pem
echo "[INFO] Certificate bundle installed to /etc/ssl/cert.pem"

# Install Nix with SSL certificate
echo "[INFO] Installing Nix in daemon mode..."
export NIX_SSL_CERT_FILE=/etc/ssl/cert.pem
bash <(curl -L https://nixos.org/nix/install) --daemon --yes

if [ $? -eq 0 ]; then
    echo "[INFO] Nix installation completed successfully"
else
    echo "[ERROR] Nix installation failed"
    exit 1
fi

# Configure nix.conf
echo "[INFO] Configuring nix.conf..."
NIX_CONF="/etc/nix/nix.conf"

# Backup existing config
if [ -f "$NIX_CONF" ]; then
    sudo cp "$NIX_CONF" "$NIX_CONF.bkp"
    echo "[INFO] Backed up existing nix.conf to nix.conf.bkp"
fi

sudo tee "$NIX_CONF" > /dev/null << EOF
# Experimental features
experimental-features = nix-command flakes

# Build users group
build-users-group = nixbld

# SSL certificate
ssl-cert-file = /etc/ssl/cert.pem
EOF

echo "[INFO] nix.conf configured with experimental features and SSL certificate"
echo "[SUCCESS] Nix installation and configuration completed!"
echo "[NOTE] Users should restart their shell or system to use Nix"
