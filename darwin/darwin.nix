{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.home-manager
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.dotfiles";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nix;
    settings = {
      "extra-experimental-features" = [ "nix-command" "flakes" ];
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;  # default shell on catalina
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  fonts.fontDir.enable = true;
  fonts.fonts = [
    pkgs.monaspace
    pkgs.atkinson-hyperlegible
  ];

  services = {

  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      # "bartender"
      # "brave-browser"
      "firefox"
      # "karabiner-elements"
      "obsidian"
      "raycast"
      "rectangle"
      # "soundsource"
      "wezterm"
    ];

    masApps = {
      "Macfamilytree-10"  = 1567970985;
      "Tailscale" = 1475387142;
      "Amphetamine" = 937984704;
    };
  };

  system.defaults = {
    dock = {
      autohide = true;
      # orientation = "left";
      # show-process-indicators = false;
      # show-recents = false;
      # static-only = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };
  };
}