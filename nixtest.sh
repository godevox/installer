#!/bin/bash
set -euo pipefail

# Color codes
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}========== GODEVOX NIX TEST ==========${NC}"

log()    { echo -e "${CYAN}[GoDevox]${NC} $1"; }
success(){ echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn()   { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error()  { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Check Nix version
log "Checking Nix version..."
if nix --version; then
    success "Nix is installed."
else
    error "Nix is not installed or not in PATH."
    exit 1
fi

# 2. Show Nix configuration
log "Showing Nix configuration (nix config show)..."
if nix config show; then
    success "Nix configuration displayed."
else
    warn "Could not display Nix configuration."
fi

# 3. Determine SSL certificate path used by Nix
log "Checking which CA certificate file Nix is configured to use..."
NIX_SSL_CERT_FILE=$(nix config show | grep -E '^ssl-cert-file' | awk '{print $3}' || true)
if [ -n "$NIX_SSL_CERT_FILE" ]; then
    success "Nix is configured to use CA certificate file: $NIX_SSL_CERT_FILE"
    if [ -f "$NIX_SSL_CERT_FILE" ]; then
        success "CA certificate file exists."
    else
        error "CA certificate file does not exist: $NIX_SSL_CERT_FILE"
    fi
else
    warn "Nix does not have ssl-cert-file set in config. Likely using system default."
fi

# 4. Test connectivity to cache.nixos.org using Nix
log "Testing connectivity to cache.nixos.org using a Nix command..."
if nix path-info nixpkgs#hello >/dev/null 2>&1; then
    success "Nix successfully connected to cache.nixos.org and fetched metadata."
else
    error "Nix could not connect to cache.nixos.org or had an SSL error."
    exit 1
fi

# 5. Run some default Nix diagnostics
log "Running 'nix doctor' for diagnostics..."
if nix doctor; then
    success "Nix doctor completed successfully."
else
    warn "Nix doctor found issues. Please review the output above."
fi

log "Testing basic Nix evaluation..."
if nix eval --expr '1 + 1'; then
    success "Nix eval works."
else
    error "Nix eval failed."
fi

echo -e "${GREEN}\nAll Nix tests completed."
