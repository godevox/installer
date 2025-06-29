#!/bin/bash
set -euo pipefail

# Color codes
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Simple GoDevox branding
echo -e "${BOLD}${CYAN}========== GODEVOX INSTALLER ==========${NC}"

log()    { echo -e "${CYAN}[GoDevox]${NC} $1"; }
success(){ echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn()   { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error()  { echo -e "${RED}[ERROR]${NC} $1"; }

log "Detecting Linux distribution..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    log "Distribution detected: $DISTRO"
else
    error "Cannot detect Linux distribution."
    exit 1
fi

log "Updating system and installing dependencies..."
case "$DISTRO" in
    ubuntu|debian)
        sudo apt-get update -y && success "System updated (apt-get)."
        sudo apt-get install -y curl xz-utils && success "Installed curl and xz-utils."
        ;;
    fedora)
        sudo dnf update -y && success "System updated (dnf)."
        sudo dnf install -y curl xz && success "Installed curl and xz."
        ;;
    *)
        error "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

log "Installing Nix package manager (multi-user mode)..."
if sh <(curl -L https://nixos.org/nix/install) --daemon; then
    success "Nix installed successfully."
else
    error "Nix installation failed."
    exit 1
fi

NIX_CONF="/etc/nix/nix.conf"
log "Configuring Nix flakes support..."
if [ -f "$NIX_CONF" ]; then
    sudo cp "$NIX_CONF" "${NIX_CONF}.bak" && success "Backed up existing nix.conf."
else
    warn "No existing nix.conf found, skipping backup."
fi
echo "experimental-features = nix-command flakes" | sudo tee -a "$NIX_CONF" && success "Enabled flakes in nix.conf."

log "Sourcing Nix environment..."
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    success "Nix environment sourced."
else
    warn "Nix environment script not found, you may need to restart your shell."
fi

log "Verifying Nix installation and configuration..."
if nix --version; then
    success "Nix version command succeeded."
else
    error "Nix is not available in PATH."
fi

if nix config show | grep experimental-features; then
    success "Nix flakes feature is enabled."
else
    error "Nix flakes feature is NOT enabled."
fi

echo -e "${GREEN}\nInstallation completed!"
