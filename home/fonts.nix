# Font configuration for home-manager
{ config, pkgs, lib, ... }:

let
  # Detect if we're on NixOS or Darwin (where fonts are managed at system level)
  # On these systems, fonts should NOT be installed via home-manager
  systemManagedFonts = pkgs.stdenv.isDarwin || (builtins.pathExists /etc/NIXOS);
  
  # For non-NixOS Linux, we need to install fonts via home-manager
  isStandaloneLinux = pkgs.stdenv.isLinux && !systemManagedFonts;
in
{
  # Font installation approach:
  # - macOS (Darwin): Fonts MUST be installed at system level (darwin/darwin.nix)
  # - NixOS: Fonts should be installed at system level (nixos/fonts.nix) for ALL users
  # - Non-NixOS Linux: Fonts can be installed per-user via home-manager
  # 
  # Only install fonts via home-manager on non-NixOS Linux systems
  home.packages = with pkgs; lib.optionals isStandaloneLinux [
    # IMPORTANT: Install Nerd Font versions for powerline support
    # These include all powerline symbols and icons
    
    # Primary Nerd Fonts with powerline symbols
    nerd-fonts.jetbrains-mono     # JetBrainsMono Nerd Font
    nerd-fonts.fira-code          # FiraCode Nerd Font
    nerd-fonts.hack               # Hack Nerd Font
    nerd-fonts.sauce-code-pro     # SauceCodePro Nerd Font (Source Code Pro)
    nerd-fonts.ubuntu-mono        # UbuntuMono Nerd Font
    nerd-fonts.meslo-lg           # MesloLG Nerd Font
    nerd-fonts.inconsolata        # Inconsolata Nerd Font
    nerd-fonts.dejavu-sans-mono   # DejaVuSansMono Nerd Font
    nerd-fonts.droid-sans-mono    # DroidSansMono Nerd Font
    nerd-fonts.space-mono         # SpaceMono Nerd Font
    
    # Regular programming fonts (without powerline)
    # These are fallbacks if Nerd Font versions aren't recognized
    monaspace  # GitHub's innovative superfamily of fonts for code
    fira-code-symbols
    cascadia-code
    fantasque-sans-mono
    victor-mono
    
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
    
    # Note: google-fonts package removed due to conflicts with individual font packages
    # All needed fonts are installed individually above
    
    # Icon fonts
    font-awesome
    material-design-icons
  ];

  # Fontconfig for Linux systems (ensures fonts are properly registered)
  fonts.fontconfig.enable = lib.mkIf isStandaloneLinux true;
  
  # Post-installation activation script for font setup
  home.activation = lib.mkIf isStandaloneLinux {
    refreshFontCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Refresh font cache after installing fonts
      $DRY_RUN_CMD ${pkgs.fontconfig}/bin/fc-cache -f $VERBOSE_ARG || true
      
      # Verify Nerd Fonts are available
      if [ -z "$DRY_RUN" ]; then
        echo "Checking for Nerd Font installation..."
        if ${pkgs.fontconfig}/bin/fc-list | ${pkgs.gnugrep}/bin/grep -q "Nerd Font"; then
          echo "✓ Nerd Fonts successfully installed"
          echo "Available Nerd Fonts:"
          ${pkgs.fontconfig}/bin/fc-list : family | ${pkgs.gnugrep}/bin/grep "Nerd Font" | ${pkgs.coreutils}/bin/sort -u | ${pkgs.coreutils}/bin/head -5
        else
          echo "⚠ Warning: Nerd Fonts may not be properly installed"
        fi
      fi
    '';
  };
  
  # Font configuration notes:
  # - On macOS: Fonts MUST be installed via darwin.nix (system-level)
  #   Home-manager cannot properly register fonts with macOS
  # - On Linux/NixOS: Fonts can be installed via home-manager (user-level)
  # - fontconfig settings must be configured at system level
  # 
  # Recommended font defaults:
  # - Default serif: SF Pro Text, Times New Roman, Liberation Serif
  # - Default sans: SF Pro Text, Helvetica Neue, Liberation Sans  
  # - Default mono: JetBrains Mono, Monaspace Neon, SF Mono
  # - Subpixel rendering: RGB with default LCD filter
  # - Hinting: slight with autohint disabled
  # - Antialiasing: enabled

  # Configure terminal fonts in various applications
  programs.alacritty.settings = lib.mkIf config.programs.alacritty.enable {
    font = {
      normal = { family = "JetBrains Mono"; style = "Regular"; };
      bold = { family = "JetBrains Mono"; style = "Bold"; };
      italic = { family = "JetBrains Mono"; style = "Italic"; };
      size = 14.0;
    };
  };

  programs.kitty.settings = lib.mkIf config.programs.kitty.enable {
    font_family = "JetBrains Mono";
    bold_font = "auto";
    italic_font = "auto";
    bold_italic_font = "auto";
    font_size = "14.0";
    
    # Font features
    font_features = "JetBrainsMono-Regular +zero +onum";
    disable_ligatures = "never";
    
    # Adjust line height and letter spacing
    adjust_line_height = 0;
    adjust_column_width = 0;
  };

  # Configure WezTerm fonts (if using our WezTerm config)
  home.file.".config/wezterm/fonts.lua" = {
    text = ''
      local wezterm = require 'wezterm'
      
      return {
        -- Font configuration
        font = wezterm.font_with_fallback {
          'JetBrains Mono',
          'Monaspace Neon',
          'SF Mono',
          'Menlo',
        },
        
        font_size = 14.0,
        line_height = 1.2,
        
        -- Font shaping and rendering
        harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
        
        -- Different fonts for different text types
        font_rules = {
          {
            intensity = 'Bold',
            font = wezterm.font('JetBrains Mono', { weight = 'Bold' }),
          },
          {
            italic = true,
            font = wezterm.font('JetBrains Mono', { style = 'Italic' }),
          },
          {
            intensity = 'Bold',
            italic = true,
            font = wezterm.font('JetBrains Mono', { weight = 'Bold', style = 'Italic' }),
          },
        },
      }
    '';
  };

  # Font management script
  home.file.".local/bin/font-preview" = {
    text = ''
      #!/usr/bin/env bash
      # Font preview script
      
      set -euo pipefail
      
      FONTS=(
          "JetBrains Mono"
          "Monaspace Neon"
          "Fira Code"
          "Hack"
          "Source Code Pro"
          "Ubuntu Mono"
          "Cascadia Code"
          "SF Mono"
      )
      
      TEXT="The quick brown fox jumps over the lazy dog 0123456789"
      CODE_TEXT="const hello = () => { return 'Hello, World!'; }; // <= != >= =>"
      
      echo "🔤 Font Preview"
      echo "==============="
      echo
      
      for font in "''${FONTS[@]}"; do
          echo "Font: $font"
          echo "Text: $TEXT"
          echo "Code: $CODE_TEXT"
          echo "---"
          echo
      done
      
      echo "To test a specific font in terminal:"
      echo "  printf '\033]50;font=%s\007' 'JetBrains Mono'"
      echo
      echo "Available programming fonts:"
      fc-list : family | grep -i -E "(mono|code|source|fira|jetbrains|hack|ubuntu)" | sort | uniq
    '';
    executable = true;
  };

  # Font installation and management script
  home.file.".local/bin/font-install" = {
    text = ''
      #!/usr/bin/env bash
      # Font installation helper
      
      set -euo pipefail
      
      FONT_DIR="$HOME/.local/share/fonts"
      mkdir -p "$FONT_DIR"
      
      echo "🔤 Font Installation Helper"
      echo "=========================="
      echo
      
      case "''${1:-help}" in
          "list")
              echo "Installed fonts:"
              fc-list : family | sort | uniq
              ;;
          "programming")
              echo "Programming fonts:"
              fc-list : family | grep -i -E "(mono|code|source|fira|jetbrains|hack|ubuntu|cascadia)" | sort | uniq
              ;;
          "nerdfonts")
              echo "Nerd Fonts:"
              fc-list : family | grep -i "nerd" | sort | uniq
              ;;
          "reload")
              echo "Reloading font cache..."
              fc-cache -f -v
              echo "✅ Font cache reloaded"
              ;;
          "install")
              if [ -z "''${2:-}" ]; then
                  echo "Usage: $0 install <font-file>"
                  exit 1
              fi
              
              FONT_FILE="$2"
              if [ ! -f "$FONT_FILE" ]; then
                  echo "❌ Font file not found: $FONT_FILE"
                  exit 1
              fi
              
              cp "$FONT_FILE" "$FONT_DIR/"
              fc-cache -f -v
              echo "✅ Font installed: $(basename "$FONT_FILE")"
              ;;
          *)
              echo "Usage: $0 {list|programming|nerdfonts|reload|install <file>}"
              echo
              echo "Commands:"
              echo "  list         - List all installed fonts"
              echo "  programming  - List programming fonts"  
              echo "  nerdfonts    - List Nerd Fonts"
              echo "  reload       - Reload font cache"
              echo "  install      - Install a font file"
              ;;
      esac
    '';
    executable = true;
  };

  # VSCode font configuration (if VSCode is used)
  programs.vscode.userSettings = lib.mkIf config.programs.vscode.enable {
    "editor.fontFamily" = "'JetBrains Mono', 'Monaspace Neon', 'SF Mono', Menlo, Monaco, 'Courier New', monospace";
    "editor.fontSize" = 14;
    "editor.fontLigatures" = true;
    "editor.fontWeight" = "400";
    "terminal.integrated.fontFamily" = "'JetBrains Mono'";
    "terminal.integrated.fontSize" = 14;
  };
}