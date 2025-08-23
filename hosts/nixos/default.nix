# NixOS Linux system configuration
{ config, pkgs, ... }:

{
  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Time zone and locale
  time.timeZone = "America/New_York"; # Adjust as needed
  i18n.defaultLocale = "en_US.UTF-8";

  # Users configuration
  users.users.nixos = {
    isNormalUser = true;
    description = "NixOS User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
    home-manager
  ];

  # Services
  services = {
    openssh.enable = true;
    docker.enable = true;
  };

  # Programs
  programs = {
    fish.enable = true;
    git.enable = true;
  };

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # System version
  system.stateVersion = "23.11";
}