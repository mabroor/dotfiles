{
  description = "Mabroor's Nix System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # darwin/home-manager/agenix are consumed via `inputs` inside lib/mkSystem.nix
  # rather than destructured here.
  outputs = { self, nixpkgs, ... } @ inputs:
    let
      inherit (import ./lib/mkSystem.nix { inherit inputs; }) mkDarwin mkNixOS mkHome;

      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      # nixpkgs 26.11 dropped x86_64-darwin, so Intel Macs get no per-system
      # outputs. The Mabroors-MacBook-Pro configuration below is kept for
      # reference but cannot be built against current nixpkgs.
      darwinSystems = [ "aarch64-darwin" ];
      allSystems = linuxSystems ++ darwinSystems;

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system:
        f (import nixpkgs { inherit system; config.allowUnfree = true; }));

      devPackages = pkgs: import ./lib/dev-packages.nix { inherit pkgs; };
    in
    {
      nixosConfigurations = {
        nixos = mkNixOS {
          hostname = "nixos";
          system = "x86_64-linux";
          username = "nixos";
        };
      };

      darwinConfigurations = {
        AMAFCXNW09RYR = mkDarwin {
          hostname = "AMAFCXNW09RYR";
          system = "aarch64-darwin";
          username = "mabroor.ahmed";
        };

        # Intel Mac. nixpkgs 26.11 dropped x86_64-darwin support, so this cannot
        # currently be built — it needs either retiring or pinning to a nixpkgs
        # from before the drop.
        Mabroors-MacBook-Pro = mkDarwin {
          hostname = "Mabroors-MacBook-Pro";
          system = "x86_64-darwin";
          username = "mabroor";
        };
      };

      homeConfigurations = {
        "mabroor" = mkHome {
          system = "x86_64-linux";
          username = "mabroor";
          homeDirectory = "/home/mabroor";
        };
      };

      # Per-language development shells. Language toolchains live here rather
      # than in the user profile, so a machine only materialises the toolchains
      # for projects it actually builds. Use with direnv:  echo "use flake
      # github:mabroor/dotfiles#rust" > .envrc
      devShells = forAllSystems (pkgs:
        let dev = devPackages pkgs; in
        {
          default = pkgs.mkShell {
            packages = dev.nix;
          };
          rust = pkgs.mkShell {
            packages = dev.rust;
            env.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          };
          go = pkgs.mkShell { packages = dev.go; };
          python = pkgs.mkShell { packages = dev.python; };
          # Adds the data-science/web library stack on top of the python shell.
          python-data = pkgs.mkShell { packages = dev.python ++ dev.pythonData; };
          javascript = pkgs.mkShell { packages = dev.javascript; };
        });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);

      # `nix flake check` only shallow-checks non-standard outputs like
      # darwinConfigurations, so every configuration is forced explicitly here.
      # Without this, a Darwin config can be broken for months and CI stays green.
      checks = forAllSystems (pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;

          # Derivations that prove a configuration evaluates and can be built.
          configChecks =
            nixpkgs.lib.optionalAttrs (builtins.elem system linuxSystems)
              {
                nixos-nixos = self.nixosConfigurations.nixos.config.system.build.toplevel;
                home-mabroor = self.homeConfigurations."mabroor".activationPackage;
              }
            // nixpkgs.lib.optionalAttrs (system == "aarch64-darwin") {
              darwin-AMAFCXNW09RYR = self.darwinConfigurations.AMAFCXNW09RYR.system;
            };
        in
        configChecks // {
          # Lint the Nix itself. statix catches anti-patterns, deadnix catches
          # unused bindings — both were installed as user packages but never run.
          lint = pkgs.runCommand "lint-nix" { nativeBuildInputs = [ pkgs.statix pkgs.deadnix ]; } ''
            cd ${self}
            statix check .
            # templates/ is scaffolding meant to be copied and edited, where an
            # unused `self` argument is conventional.
            deadnix --fail --exclude ./templates .
            touch $out
          '';

          format = pkgs.runCommand "check-format" { nativeBuildInputs = [ pkgs.nixpkgs-fmt ]; } ''
            cd ${self}
            nixpkgs-fmt --check .
            touch $out
          '';
        });

      # Project templates for quick development setup
      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust project with comprehensive development environment";
        };

        javascript = {
          path = ./templates/javascript;
          description = "JavaScript/Node.js project with modern tooling";
        };

        python = {
          path = ./templates/python;
          description = "Python project with development and packaging setup";
        };

        go = {
          path = ./templates/go;
          description = "Go project with development and linting setup";
        };

        default = self.templates.rust;
      };
    };
}
