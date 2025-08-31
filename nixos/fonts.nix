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
    
    # Install fonts system-wide for all users
    packages = with pkgs; [
      # Programming fonts - Nerd Fonts
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
      
      # Programming fonts - Regular (only those without Nerd Font variants)
      monaspace  # No Nerd Font variant available
      fira-code-symbols  # Symbols package, complements Nerd Font
      cascadia-code  # No Nerd Font variant available
      fantasque-sans-mono  # No Nerd Font variant available
      victor-mono  # No Nerd Font variant available
      
      # System and design fonts
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
      
      # Google Fonts collection
      google-fonts
      
      # Iconic and symbol fonts
      font-awesome
      material-design-icons
      
      # Linux-specific fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      dejavu_fonts
      freefont_ttf
      unifont
    ];
    
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