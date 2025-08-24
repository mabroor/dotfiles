# Helper functions for creating system configurations
{ inputs, ... }:

let
  inherit (inputs) nixpkgs nixpkgs-stable nixpkgs-darwin darwin home-manager agenix;
in
{
  # Helper function to create a Darwin system configuration
  mkDarwin = { hostname, system, username, homeDirectory ? "/Users/${username}" }:
    darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ../hosts/${hostname}
        agenix.darwinModules.default
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ../home/home.nix;
            sharedModules = [ agenix.homeManagerModules.default ];
          };
          users.users.${username}.home = homeDirectory;
        }
      ];
      specialArgs = { inherit inputs; };
    };

  # Helper function to create a NixOS system configuration  
  mkNixOS = { hostname, system, username ? "nixos" }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ../hosts/${hostname}
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ../home/home.nix;
            sharedModules = [ agenix.homeManagerModules.default ];
          };
        }
      ];
      specialArgs = { inherit inputs; };
    };

  # Helper to make package sets available to all configurations
  mkPkgSet = system: {
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
    pkgs-darwin = import nixpkgs-darwin { inherit system; config.allowUnfree = true; };
  };
}