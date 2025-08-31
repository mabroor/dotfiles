# NixOS Linux system configuration
{ config, pkgs, ... }:

{
  # Import modules
  imports = [
    ../../nixos/fonts.nix  # System-wide font configuration
  ];

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Filesystem configuration (adjust for your actual system)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

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
  };

  # Virtualisation
  virtualisation = {
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