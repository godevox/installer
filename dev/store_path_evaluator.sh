#!/usr/bin/env bash

nixpkgs_url="https://nixos.org/channels/nixos-25.05/nixexprs.tar.xz"

tools=(
  corretto11 corretto17 corretto21
  zulu8 zulu11 zulu17 zulu zulu24
  go go_1_23
  python310 python311 python313
  nodejs_20 nodejs_22 nodejs_24
  lua zig dotnet-sdk_8
  maven gradle kubectl kind syft grype
  podman podman-compose
  upx brotli zstd xz zip unzip
  wget curl nmap traceroute iperf3 socat tcpdump whois dig
  jq yq xsv dasel gnupg git htop
)

systems=(
  x86_64-linux
  aarch64-darwin
)

echo "Evaluating using nixpkgs: $nixpkgs_url"
echo

for tool in "${tools[@]}"; do
  echo "=== $tool ==="
  for system in "${systems[@]}"; do
    echo "[$system]"

    # Evaluate version
    version=$(nix eval --raw --impure --expr "
      let pkgs = import (fetchTarball \"$nixpkgs_url\") { system = \"$system\"; };
      in if pkgs ? ${tool} then pkgs.${tool}.version or \"n/a\" else \"not-available\"
    " 2>/dev/null)

    # Evaluate outPath
    outpath=$(nix eval --raw --impure --expr "
      let pkgs = import (fetchTarball \"$nixpkgs_url\") { system = \"$system\"; };
      in if pkgs ? ${tool} then pkgs.${tool}.outPath else \"not-available\"
    " 2>/dev/null)

    echo "  Version : $version"
    echo "  OutPath : $outpath"
    echo
  done
done
