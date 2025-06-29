#!/bin/bash
set -euo pipefail

# System update and dependencies
sudo dnf update -y
sudo dnf install -y curl xz

# Install Nix multi-user with systemd support
sh <(curl -L https://nixos.org/nix/install) --daemon

# Configure flakes
NIX_CONF="/etc/nix/nix.conf"
sudo cp "$NIX_CONF" "${NIX_CONF}.bak" 2>/dev/null || true
echo "experimental-features = nix-command flakes" | sudo tee -a "$NIX_CONF"

# Source environment
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Verification tests
echo -e "\n\033[1;32mNIX INSTALL VERIFICATION:\033[0m"
nix --version
nix config show | grep experimental-features
