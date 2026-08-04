# Helper functions for creating system and home configurations.
#
# All three constructors funnel through the same nixpkgs instance and the same
# home-manager wiring, so a change to nixpkgs.config applies everywhere rather
# than to whichever call site remembered it.
{ inputs, ... }:

let
  inherit (inputs) nixpkgs darwin home-manager agenix;

  # Central nixpkgs settings. Previously this lived in a helper that was never
  # called, which meant allowUnfree was silently inactive everywhere.
  nixpkgsConfig = {
    allowUnfree = true;
  };

  # Shared home-manager wiring used by both system constructors.
  hmModule = { username }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${username} = import ../home/home.nix;
      sharedModules = [ agenix.homeManagerModules.default ];
      extraSpecialArgs = { inherit inputs; };
    };
  };
in
{
  mkDarwin = { hostname, system, username, homeDirectory ? "/Users/${username}" }:
    darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ../hosts/${hostname}
        agenix.darwinModules.default
        home-manager.darwinModules.home-manager
        (hmModule { inherit username; })
        {
          networking.hostName = hostname;
          nixpkgs.config = nixpkgsConfig;
          users.users.${username}.home = homeDirectory;
          # Required since nix-darwin 25.05 for user-scoped system.defaults.
          system.primaryUser = username;
        }
      ];
      specialArgs = { inherit inputs; };
    };

  mkNixOS = { hostname, system, username ? "nixos" }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ../hosts/${hostname}
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        (hmModule { inherit username; })
        {
          networking.hostName = hostname;
          nixpkgs.config = nixpkgsConfig;
        }
      ];
      specialArgs = { inherit inputs; };
    };

  # Standalone home-manager, for machines whose system config we do not own.
  # Goes through the same nixpkgs instance as the system constructors so it
  # picks up nixpkgs.config rather than raw legacyPackages.
  mkHome = { system, username, homeDirectory }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };
      modules = [
        ../home/home.nix
        agenix.homeManagerModules.default
        { home = { inherit username homeDirectory; }; }
      ];
      extraSpecialArgs = { inherit inputs; };
    };
}
