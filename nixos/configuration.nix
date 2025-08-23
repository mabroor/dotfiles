# NixOS system configuration
{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the host-specific configuration
    ../hosts/nixos
  ];

  # This file serves as a bridge for the legacy path structure
  # The actual configuration is in hosts/nixos/default.nix
}