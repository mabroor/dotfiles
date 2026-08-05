# Shared font package lists.
#
# Consumed by darwin/darwin.nix (system fonts), nixos/fonts.nix (system fonts)
# and home/fonts.nix (per-user fonts on non-NixOS Linux). Keeping one list here
# stops the three sites from drifting apart.
{ pkgs }:

rec {
  # Programming fonts patched with powerline/devicon glyphs.
  nerdFonts = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.sauce-code-pro
    nerd-fonts.ubuntu-mono
    nerd-fonts.meslo-lg
    nerd-fonts.inconsolata
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.space-mono
  ];

  # Programming fonts with no Nerd Font variant available.
  programming = with pkgs; [
    monaspace
    fira-code-symbols
    cascadia-code
    fantasque-sans-mono
    victor-mono
  ];

  design = with pkgs; [
    atkinson-hyperlegible
    inter
    roboto
    roboto-mono
    roboto-slab
    open-sans
    liberation_ttf
    eb-garamond
    gentium
    lato
    montserrat
    source-sans-pro
    source-serif-pro
    work-sans
  ];

  icons = with pkgs; [
    font-awesome
    material-design-icons
  ];

  # Linux needs explicit Noto/DejaVu coverage for CJK and emoji.
  linuxExtra = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    dejavu_fonts
    freefont_ttf
    unifont
  ];

  # Base set shared by every platform.
  common = nerdFonts ++ programming ++ design ++ icons;

  # System-level installs can afford the full Google Fonts collection.
  # It is omitted from the home-manager set because the individual font
  # packages above collide with it when linked into a single user profile.
  system = common ++ [ pkgs.google-fonts ];

  darwin = system;
  nixos = system ++ linuxExtra;
  home = common;
}
