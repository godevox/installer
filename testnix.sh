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

# 4. Run Nix configuration check
log "Running 'nix config check' for diagnostics..."
if nix config check; then
    success "Nix configuration check completed successfully."
else
    warn "Nix configuration check found issues. Please review the output above."
fi

# 5. Test basic Nix evaluation
log "Testing basic Nix evaluation..."
if nix eval --expr '1 + 1'; then
    success "Nix eval works."
else
    error "Nix eval failed."
fi

# 6. Dry run build of hello package
log "Performing dry-run build of 'hello' package to verify build and cache access..."
if nix build --dry-run nixpkgs#hello; then
    success "Dry-run build of 'hello' succeeded."
else
    error "Dry-run build of 'hello' failed."
fi

echo -e "${GREEN}\nAll Nix tests completed. GoDevox Nix environment looks good!${NC}"
