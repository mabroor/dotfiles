# Apple Silicon Mac (aarch64-darwin) - AMAFCXNW09RYR
{ config, pkgs, ... }:

{
  # Import shared Darwin configuration
  imports = [
    ../../darwin/darwin.nix
  ];

  # Host-specific settings
  networking.hostName = "AMAFCXNW09RYR";
  
  # Apple Silicon specific packages or configurations can go here
  environment.systemPackages = with pkgs; [
    # Add any Apple Silicon specific packages here
  ];

  # Host-specific homebrew casks if needed
  homebrew.casks = [
    # Any host-specific casks can be added here
  ];

  # Host-specific system defaults
  system.defaults = {
    # Any host-specific system defaults can be added here
  };
}