# NixOS system-wide font configuration
{ config, pkgs, ... }:

{
  # Enable font configuration
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    # Note: NixOS automatically updates font cache during system activation
    # when fontDir.enable = true. Fonts are available system-wide immediately.
    # The fontconfig.cache32Bit option ensures 32-bit apps can also use the fonts.

    # Install fonts system-wide for all users. Shared list in lib/fonts.nix.
    packages = (import ../lib/fonts.nix { inherit pkgs; }).nixos;

    # Font configuration
    fontconfig = {
      enable = true;

      # Default font settings
      defaultFonts = {
        serif = [ "Liberation Serif" "DejaVu Serif" "Noto Serif" ];
        sansSerif = [ "Inter" "Liberation Sans" "DejaVu Sans" "Noto Sans" ];
        monospace = [ "JetBrains Mono" "Monaspace Neon" "Liberation Mono" "DejaVu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };

      # Font rendering settings
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
        autohint = false;
      };

      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };

      # Cache settings
      cache32Bit = true;

      # Allow bitmap fonts (for terminal emulators)
      allowBitmaps = true;

      # User configuration
      includeUserConf = true;
    };
  };
}
