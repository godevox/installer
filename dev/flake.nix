{
  description = "Global development environment with Zig, Go, Java, Node.js, Python, Rust, and tools";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Languages
            zig
            go
            zulu # OpenJDK from Azul Zulu
            maven
            nodejs_22
            python313
            uv # Python package manager
            rustup # Rust toolchain installer
            
            # Tools  
            git
            brotli
            upx # Ultimate Packer for eXecutables
            xz # Compression utility
            jq
            yq-go # YAML processor
            yaml2json
            httpx # HTTP client
            asciinema # Terminal recorder
            
            # Additional useful dev tools
            curl
            wget
            tree
            htop
          ];
          
          shellHook = ''
            echo "Global Development Environment Ready!"
            echo "Languages:"
            echo "  Zig:      $(zig version)"
            echo "  Go:       $(go version | cut -d' ' -f3)"
            echo "  Java:     $(java -version 2>&1 | head -n1)"
            echo "  Maven:    $(mvn -version | head -n1)"
            echo "  Node.js:  $(node --version)"
            echo "  Python:   $(python --version)"
            echo "  Rust:     $(rustup show | head -n1)"
            echo ""
            echo "Tools: git, uv, brotli, upx, xz, jq, yq, httpx, asciinema"
          '';
        };
      });
}
