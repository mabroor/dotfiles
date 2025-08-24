# Intel Mac (x86_64-darwin) - Mabroors-MacBook-Pro
{ config, pkgs, ... }:

{
  # Import shared Darwin configuration
  imports = [
    ../../darwin/darwin.nix
  ];

  # Host-specific settings
  networking.hostName = "Mabroors-MacBook-Pro";
  
  # Intel Mac specific packages or configurations can go here
  environment.systemPackages = with pkgs; [
    # Add any Intel Mac specific packages here
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