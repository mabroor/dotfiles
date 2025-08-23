
{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./shell.nix
    ./wezterm.nix
  ];

  home = {
    stateVersion = "23.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      pkgs.marksman
      pkgs.nixd
      pkgs.ripgrep
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # hammerspoon = lib.mkIf pkgs.stdenvNoCC.isDarwin {
      #   source = ./../config/hammerspoon;
      #   target = ".hammerspoon";
      #   recursive = true;
      # };
    };

    sessionVariables = {
    };
  };

  programs = {
    # Program configurations are now modularized:
    # - Shell configurations (Fish, Bash, direnv) are in ./shell.nix
    # - Git configuration is in ./git.nix
    # - WezTerm configuration is in ./wezterm.nix
  };
}
