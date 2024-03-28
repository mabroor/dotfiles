# Dotfiles

This is to describe the barebones development system I use. Support Intel and Silicon Macs.

## Install Nix

On OSX: [Determinate Systems Installer](https://github.com/DeterminateSystems/nix-installer).

## Bootstrap


### Darwin/Linux

`nix run nix-darwin -- switch --flake github:mabroor/dotfiles`

## Update

### NixOS

`sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles`

### Darwin

`darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles`

## Home Manager

You could use something like this to import my home-manager standalone.

```nix
{ config, pkgs, ... }: {
  home-manager.users.evan = import ./home/home.nix;
}
```

