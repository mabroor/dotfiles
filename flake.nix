{
  description = "Mabroor's Nix System Configuration";

  inputs = {
    # Primary nixpkgs - using unstable for latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Additional channels for stability and Darwin-specific packages
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    
    # Secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    darwin,
    flake-utils,
    home-manager,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-darwin,
    agenix,
    ...
  } @ inputs: 
  let
    # Import our helper functions
    inherit (import ./lib/mkSystem.nix { inherit inputs; }) mkDarwin mkNixOS;
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
        homeDirectory = "/Users/mabroor.ahmed";
      };
      
      Mabroors-MacBook-Pro = mkDarwin {
        hostname = "Mabroors-MacBook-Pro";
        system = "x86_64-darwin";
        username = "mabroor";
        homeDirectory = "/Users/mabroor";
      };
    };
  };
}