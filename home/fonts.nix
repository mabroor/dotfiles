# Font configuration for home-manager
{ config, pkgs, lib, ... }:

{
  # Additional fonts managed by home-manager
  home.packages = with pkgs; [
    # Additional Nerd Fonts not covered by system
    (nerdfonts.override { 
      fonts = [ 
        "Meslo" 
        "Inconsolata" 
        "DejaVuSansMono"
        "DroidSansMono"
        "AnonymousPro"
        "Terminus"
        "SpaceMono"
      ]; 
    })
    
    # Google Fonts
    google-fonts
    
    # Additional programming fonts
    anonymous-pro
    inconsolata
    fantasque-sans-mono
    comic-mono
    victor-mono
    
    # Design and display fonts
    cooper-hewitt
    eb-garamond
    gentium
    lato
    montserrat
    nunito
    oswald
    playfair-display
    raleway
    source-sans
    source-serif
    work-sans
  ];

  # Font configuration for applications
  fonts.fontconfig = {
    enable = true;
    
    # Default fonts
    defaultFonts = {
      serif = [ "SF Pro Text" "Times New Roman" "Liberation Serif" ];
      sansSerif = [ "SF Pro Text" "Helvetica Neue" "Liberation Sans" ];
      monospace = [ "JetBrains Mono" "Monaspace Neon" "SF Mono" "Liberation Mono" ];
      emoji = [ "Apple Color Emoji" "Noto Color Emoji" ];
    };
    
    # Subpixel rendering
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    
    # Hinting and antialiasing
    hinting = {
      enable = true;
      style = "slight";
      autohint = false;
    };
    
    antialias = true;
  };

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