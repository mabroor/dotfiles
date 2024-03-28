{
  description = "Mabroor's Nix System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
    ...
  } @ inputs: {
    nixosConfigurations = {
      "nixos" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.nixos = import ./home/home.nix;
          }
        ];
      };
    };

    darwinConfigurations = {
      "AMAFCXNW09RYR" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              users.mabroor_ahmed = import ./home/home.nix;
            };
            users.users.mabroor_ahmed.home = "/Users/mabroor.ahmed";
          }
        ];
        specialArgs = { inherit inputs; };
      };
      
      "Mabroors-MacBook-Pro" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./darwin/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
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