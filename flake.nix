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
  };

  outputs = {
    self,
    darwin,
    flake-utils,
    home-manager,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-darwin,
    ...
  } @ inputs: {
    nixosConfigurations = {
      "nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nixos = import ./home/home.nix;
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };

    darwinConfigurations = {
      "AMAFCXNW09RYR" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/AMAFCXNW09RYR
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."mabroor.ahmed" = import ./home/home.nix;
            };
            users.users."mabroor.ahmed".home = "/Users/mabroor.ahmed";
          }
        ];
        specialArgs = { inherit inputs; };
      };
      
      "Mabroors-MacBook-Pro" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./hosts/Mabroors-MacBook-Pro
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mabroor = import ./home/home.nix;
            };
            users.users.mabroor.home = "/Users/mabroor";
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}