# Theme configuration for consistent styling across applications
{ config, pkgs, lib, ... }:

let
  # Catppuccin Macchiato color scheme
  colors = {
    base = "#24273a";      # Background
    mantle = "#1e2030";    # Darker background
    surface0 = "#363a4f";  # Surface
    surface1 = "#494d64";  # Surface 1
    surface2 = "#5b6078";  # Surface 2
    overlay0 = "#6e738d";  # Overlay 0
    overlay1 = "#8087a2";  # Overlay 1
    overlay2 = "#939ab7";  # Overlay 2
    subtext0 = "#a5adcb";  # Subtext 0  
    subtext1 = "#b7bdf8";  # Subtext 1
    text = "#cad3f5";      # Text
    
    # Accent colors
    rosewater = "#f4dbd6"; # Rosewater
    flamingo = "#f0c6c6";  # Flamingo
    pink = "#f5bde6";      # Pink
    mauve = "#c6a0f6";     # Mauve
    red = "#ed8796";       # Red
    maroon = "#ee99a0";    # Maroon
    peach = "#f5a97f";     # Peach
    yellow = "#eed49f";    # Yellow
    green = "#a6da95";     # Green
    teal = "#8bd5ca";      # Teal
    sky = "#91d7e3";       # Sky
    sapphire = "#7dc4e4";  # Sapphire
    blue = "#8aadf4";      # Blue
    lavender = "#b7bdf8";  # Lavender
  };
in
{
  # GTK theming (for Linux applications on macOS via XQuartz)
  gtk = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    
    theme = {
      name = "Catppuccin-Macchiato-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" ];
        variant = "macchiato";
      };
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    
    font = {
      name = "SF Pro Text";
      size = 11;
    };
  };

  # Qt theming
  qt = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    platformTheme = "gtk";
  };

  # Terminal color schemes
  programs.alacritty.settings = lib.mkIf config.programs.alacritty.enable {
    colors = {
      primary = {
        background = colors.base;
        foreground = colors.text;
        dim_foreground = colors.subtext1;
        bright_foreground = colors.text;
      };
      
      cursor = {
        text = colors.base;
        cursor = colors.rosewater;
      };
      
      vi_mode_cursor = {
        text = colors.base;
        cursor = colors.lavender;
      };
      
      search = {
        matches = {
          foreground = colors.base;
          background = colors.subtext0;
        };
        focused_match = {
          foreground = colors.base;
          background = colors.green;
        };
        footer_bar = {
          foreground = colors.text;
          background = colors.surface0;
        };
      };
      
      hints = {
        start = {
          foreground = colors.base;
          background = colors.yellow;
        };
        end = {
          foreground = colors.base;
          background = colors.subtext0;
        };
      };
      
      selection = {
        text = colors.base;
        background = colors.rosewater;
      };
      
      normal = {
        black = colors.surface1;
        red = colors.red;
        green = colors.green;
        yellow = colors.yellow;
        blue = colors.blue;
        magenta = colors.pink;
        cyan = colors.teal;
        white = colors.subtext1;
      };
      
      bright = {
        black = colors.surface2;
        red = colors.red;
        green = colors.green;
        yellow = colors.yellow;
        blue = colors.blue;
        magenta = colors.pink;
        cyan = colors.teal;
        white = colors.subtext0;
      };
      
      dim = {
        black = colors.surface1;
        red = colors.red;
        green = colors.green;
        yellow = colors.yellow;
        blue = colors.blue;
        magenta = colors.pink;
        cyan = colors.teal;
        white = colors.subtext1;
      };
      
      indexed_colors = [
        { index = 16; color = colors.peach; }
        { index = 17; color = colors.rosewater; }
      ];
    };
  };

  # Kitty color scheme
  programs.kitty.settings = lib.mkIf config.programs.kitty.enable {
    # Catppuccin Macchiato theme
    foreground = colors.text;
    background = colors.base;
    selection_foreground = colors.text;
    selection_background = colors.surface2;
    
    cursor = colors.rosewater;
    cursor_text_color = colors.base;
    
    url_color = colors.blue;
    
    active_border_color = colors.lavender;
    inactive_border_color = colors.overlay0;
    bell_border_color = colors.yellow;
    
    wayland_titlebar_color = colors.base;
    macos_titlebar_color = colors.base;
    
    active_tab_background = colors.mauve;
    active_tab_foreground = colors.base;
    inactive_tab_background = colors.surface0;
    inactive_tab_foreground = colors.subtext1;
    tab_bar_background = colors.base;
    
    mark1_background = colors.lavender;
    mark1_foreground = colors.base;
    mark2_background = colors.mauve;
    mark2_foreground = colors.base;
    mark3_background = colors.sapphire;
    mark3_foreground = colors.base;
    
    # Normal colors
    color0 = colors.surface1;
    color1 = colors.red;
    color2 = colors.green;
    color3 = colors.yellow;
    color4 = colors.blue;
    color5 = colors.pink;
    color6 = colors.teal;
    color7 = colors.subtext1;
    
    # Bright colors
    color8 = colors.surface2;
    color9 = colors.red;
    color10 = colors.green;
    color11 = colors.yellow;
    color12 = colors.blue;
    color13 = colors.pink;
    color14 = colors.teal;
    color15 = colors.subtext0;
    
    # Extended colors
    color16 = colors.peach;
    color17 = colors.rosewater;
  };

  # Bat (better cat) theme
  programs.bat.config = lib.mkIf config.programs.bat.enable {
    theme = "Catppuccin-macchiato";
  };

  # Dircolors for ls colors
  programs.dircolors = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # File types
      ".txt" = "01;32";
      ".md" = "01;32";
      ".json" = "01;33";
      ".yaml" = "01;33";
      ".yml" = "01;33";
      ".toml" = "01;33";
      ".xml" = "01;33";
      
      # Source code
      ".c" = "01;36";
      ".cpp" = "01;36";
      ".cc" = "01;36";
      ".h" = "01;36";
      ".hpp" = "01;36";
      ".rs" = "01;31";
      ".go" = "01;34";
      ".py" = "01;33";
      ".js" = "01;33";
      ".ts" = "01;34";
      ".html" = "01;35";
      ".css" = "01;35";
      ".scss" = "01;35";
      ".nix" = "01;34";
      
      # Archives
      ".tar" = "01;31";
      ".tgz" = "01;31";
      ".zip" = "01;31";
      ".rar" = "01;31";
      ".7z" = "01;31";
      
      # Images  
      ".jpg" = "01;35";
      ".jpeg" = "01;35";
      ".png" = "01;35";
      ".gif" = "01;35";
      ".svg" = "01;35";
      ".webp" = "01;35";
      
      # Videos
      ".mp4" = "01;35";
      ".mkv" = "01;35";
      ".avi" = "01;35";
      ".mov" = "01;35";
      ".webm" = "01;35";
      
      # Audio
      ".mp3" = "01;35";
      ".flac" = "01;35";
      ".wav" = "01;35";
      ".m4a" = "01;35";
    };
  };

  # Git delta themes
  programs.git.delta = lib.mkIf config.programs.git.enable {
    options = {
      syntax-theme = "Catppuccin-macchiato";
      side-by-side = true;
      line-numbers = true;
      decorations = true;
      navigate = true;
    };
  };

  # FZF colors
  programs.fzf.colors = lib.mkIf config.programs.fzf.enable {
    "bg+" = "#363a4f";      # Background of current line
    "bg" = "#24273a";       # Background
    "spinner" = "#f4dbd6";  # Spinner
    "hl" = "#ed8796";       # Highlighted substrings
    "fg" = "#cad3f5";       # Foreground
    "header" = "#ed8796";   # Header
    "info" = "#c6a0f6";     # Info
    "pointer" = "#f4dbd6";  # Pointer
    "marker" = "#f4dbd6";   # Marker
    "fg+" = "#cad3f5";      # Foreground of current line
    "prompt" = "#c6a0f6";   # Prompt
    "hl+" = "#ed8796";      # Highlighted substrings (current line)
  };

  # VSCode theme
  programs.vscode.userSettings = lib.mkIf config.programs.vscode.enable {
    "workbench.colorTheme" = "Catppuccin Macchiato";
    "workbench.iconTheme" = "catppuccin-macchiato";
    "editor.semanticHighlighting.enabled" = true;
    "terminal.integrated.minimumContrastRatio" = 1;
  };

  # Create theme scripts
  home.file.".local/bin/theme-switch" = {
    text = ''
      #!/usr/bin/env bash
      # Theme switching utility
      
      set -euo pipefail
      
      THEME="''${1:-macchiato}"
      
      case "$THEME" in
          "macchiato"|"dark")
              echo "🌙 Switching to Catppuccin Macchiato (Dark)"
              # You can add commands here to switch themes in running applications
              ;;
          "latte"|"light")  
              echo "☀️ Switching to Catppuccin Latte (Light)"
              # You can add commands here to switch to light theme
              ;;
          *)
              echo "Available themes: macchiato (dark), latte (light)"
              exit 1
              ;;
      esac
      
      echo "✅ Theme switched to $THEME"
      echo "Note: Some applications may need to be restarted to apply the new theme."
    '';
    executable = true;
  };

  # Wallpaper management (macOS)
  home.file.".local/bin/wallpaper" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      #!/usr/bin/env bash
      # Wallpaper management for macOS
      
      set -euo pipefail
      
      WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
      mkdir -p "$WALLPAPER_DIR"
      
      case "''${1:-help}" in
          "set")
              if [ -z "''${2:-}" ]; then
                  echo "Usage: $0 set <image-path>"
                  exit 1
              fi
              
              osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$2\""
              echo "✅ Wallpaper set to: $2"
              ;;
          "random")
              if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR")" ]; then
                  echo "❌ No wallpapers found in $WALLPAPER_DIR"
                  exit 1
              fi
              
              RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -name "*.jpg" -o -name "*.png" -o -name "*.heic" | shuf -n 1)
              osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$RANDOM_WALLPAPER\""
              echo "✅ Random wallpaper set: $(basename "$RANDOM_WALLPAPER")"
              ;;
          "list")
              echo "Available wallpapers in $WALLPAPER_DIR:"
              find "$WALLPAPER_DIR" -name "*.jpg" -o -name "*.png" -o -name "*.heic" | sort
              ;;
          *)
              echo "Usage: $0 {set <path>|random|list}"
              echo
              echo "Commands:"
              echo "  set <path>  - Set wallpaper to specific image"
              echo "  random      - Set random wallpaper from $WALLPAPER_DIR"
              echo "  list        - List available wallpapers"
              ;;
      esac
    '';
    executable = true;
  };
}