{
  description = "Rust project template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        
        # Rust toolchain with components
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" "clippy" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            
            # Development tools
            bacon
            cargo-watch
            cargo-edit
            cargo-expand
            cargo-outdated
            cargo-audit
            cargo-nextest
            cargo-flamegraph
            
            # System dependencies (adjust as needed)
            pkg-config
            openssl
            
            # Platform-specific dependencies
          ] ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.SystemConfiguration
          ] ++ lib.optionals stdenv.isLinux [
            glibc
          ];

          shellHook = ''
            echo "🦀 Rust development environment loaded!"
            echo "📦 Available tools: cargo, clippy, rustfmt, rust-analyzer"
            echo "🔧 Dev tools: bacon, cargo-watch, cargo-edit, cargo-expand"
            echo "🧪 Testing: cargo-nextest"
            echo "📊 Profiling: cargo-flamegraph"
            echo ""
            echo "Quick start:"
            echo "  cargo run       # Run the project"
            echo "  cargo test      # Run tests"
            echo "  bacon           # Watch and check"
            echo "  cargo nextest run # Better testing"
          '';

          # Environment variables
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          RUST_BACKTRACE = "1";
        };

        # Package the Rust application
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "rust-project";
          version = "0.1.0";
          
          src = ./.;
          
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
          
          buildInputs = with pkgs; [
            openssl
          ] ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.SystemConfiguration
          ];
          
          nativeBuildInputs = with pkgs; [
            pkg-config
          ];
          
          meta = with pkgs.lib; {
            description = "A Rust project";
            homepage = "https://github.com/user/project";
            license = licenses.mit;
            maintainers = [ maintainers.user ];
          };
        };
      });
}