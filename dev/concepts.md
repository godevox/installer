# Nix Concepts: Flakes, Derivations & Binary Caches

## Derivations (Traditional)
- `.drv` files - build instructions
- Attribute sets in nixpkgs
- No dependency locking
- Still underlying mechanism

## Flakes (Modern)
- Experimental but widely used
- Structured wrapper around derivations
- `flake.nix` + `flake.lock` files
- Explicit inputs/outputs, reproducible builds
- Used when building custom packages

## Binary Caches
- Pre-built packages (`.nar` files)
- Avoid rebuilding from source
- Official: `cache.nixos.org`
- Private: S3 buckets, custom servers

## Package vs Flake
- **Package**: Simple definition in nixpkgs
- **Flake**: Self-contained project with dependencies

## Tools & Abstraction
- **Devbox**: Hides flake complexity, uses `devbox.json`
- **Direct Nix**: Work with flakes/derivations directly
- **nix develop**: Enter development shell from flake
- **nix shell**: Temporary shell with packages

## Enterprise Environment Strategy
- Official installer only (`cache.nixos.org`)
- Private binary cache (curated packages)
- Avoid third-party substituters (FlakeHub, etc.)

## When You Need What
- **Binary cache only**: Consuming existing packages
- **Flakes**: Building custom packages, development environments
- **Derivations**: Legacy or direct Nix usage

## Native Nix Commands
```bash
nix develop          # Enter dev shell from flake
nix shell nixpkgs#nodejs  # Temporary shell with packages
nix run nixpkgs#hello     # Run package directly
```
