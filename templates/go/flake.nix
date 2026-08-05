{
  description = "Go project template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gopls
            golangci-lint
            gofumpt
            gotools
            gotests
            gotestsum
            delve
            govulncheck
          ];

          shellHook = ''
            echo "🐹 Go $(go version | cut -d' ' -f3)"
          '';
        };

        packages.default = pkgs.buildGoModule {
          pname = "go-project";
          version = "0.1.0";
          src = ./.;
          # Replace with the hash nix prints on first build.
          vendorHash = null;
        };

        formatter = pkgs.gofumpt;
      });
}
