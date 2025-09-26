# Zellij terminal multiplexer configuration
{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    
    # Use raw KDL configuration to avoid home-manager's incorrect keybind generation
    settings = {
      theme = "catppuccin-macchiato";
      default_shell = "fish";
      copy_on_select = false;
      scroll_buffer_size = 10000;
      mouse_mode = true;
      pane_frames = true;
      auto_layout = true;
      session_serialization = false;
      simplified_ui = false;
      default_layout = "compact";
      default_mode = "normal";
      
      ui = {
        pane_frames = {
          rounded_corners = true;
          hide_session_name = false;
        };
      };
    };
  };
  
  # Override with custom KDL config for keybinds
  xdg.configFile."zellij/config.kdl".text = ''
    theme "catppuccin-macchiato"
    default_shell "fish"
    copy_on_select false
    scroll_buffer_size 10000
    mouse_mode true
    pane_frames true
    auto_layout true
    session_serialization false
    simplified_ui false
    default_layout "compact"
    default_mode "normal"
    
    ui {
      pane_frames {
        rounded_corners true
        hide_session_name false
      }
    }
    
    keybinds {
      normal {
        // Navigation
        bind "Alt h" { MoveFocus "Left"; }
        bind "Alt l" { MoveFocus "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
        
        // Pane management
        bind "Alt |" { NewPane "Right"; }
        bind "Alt s" { NewPane "Down"; }
        bind "Alt x" { CloseFocus; }
        
        // Tab management
        bind "Alt t" { NewTab; }
        bind "Alt w" { CloseTab; }
        bind "Alt 1" { GoToTab 1; }
        bind "Alt 2" { GoToTab 2; }
        bind "Alt 3" { GoToTab 3; }
        bind "Alt 4" { GoToTab 4; }
        bind "Alt 5" { GoToTab 5; }
        
        // Session management
        bind "Alt d" { Detach; }
        bind "Alt f" { ToggleFloatingPanes; }
        bind "Alt m" { ToggleFocusFullscreen; }
        
        // Switch to search mode
        bind "Ctrl s" { SwitchToMode "Search"; }
        
        // Resize mode
        bind "Alt r" { SwitchToMode "Resize"; }
      }
      
      search {
        bind "Enter" { SwitchToMode "Normal"; }
        bind "Esc" { SwitchToMode "Normal"; }
        bind "Ctrl c" { SwitchToMode "Normal"; }
      }
      
      resize {
        bind "h" { Resize "Left"; }
        bind "j" { Resize "Down"; }
        bind "k" { Resize "Up"; }
        bind "l" { Resize "Right"; }
        bind "=" { Resize "Increase"; }
        bind "-" { Resize "Decrease"; }
        bind "Enter" { SwitchToMode "Normal"; }
        bind "Esc" { SwitchToMode "Normal"; }
      }
    }
    
    plugins {
      tab-bar { path "tab-bar"; }
      status-bar { path "status-bar"; }
      strider { path "strider"; }
      compact-bar { path "compact-bar"; }
    }
  '';
  
  # Set environment variables for proper session handling
  home.sessionVariables = {
    # Ensure Zellij uses consistent paths for session management
    ZELLIJ_CONFIG_DIR = "${config.xdg.configHome}/zellij";
    ZELLIJ_CACHE_DIR = "${config.xdg.cacheHome}/zellij";
    ZELLIJ_DATA_DIR = "${config.xdg.dataHome}/zellij";
  };

  # Ensure the data directory exists for sessions
  home.file."${config.xdg.dataHome}/zellij/.keep".text = "";

  # Fish integration - add zellij autostart
  programs.fish.loginShellInit = ''
    # Ensure Nix environment is loaded (important for SSH and su sessions)
    # This needs to run early, before interactive shell init
    if test -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        # Source home-manager session variables
        set -l hm_session_vars (bash -c ". $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh && env" 2>/dev/null)
        for var in $hm_session_vars
            set -l kv (string split -m 1 "=" $var)
            if test (count $kv) -eq 2
                set -gx $kv[1] $kv[2]
            end
        end
    end

    # Ensure user's Nix profile bins are in PATH
    set -l nix_paths \
        "$HOME/.nix-profile/bin" \
        "/nix/var/nix/profiles/default/bin" \
        "/run/current-system/sw/bin" \
        "/etc/profiles/per-user/$USER/bin"

    for p in $nix_paths
        if test -d "$p"
            fish_add_path -g "$p"
        end
    end
  '';

  programs.fish.interactiveShellInit = ''
    # Set runtime directory if not set (needed for session management)
    if test -z "$XDG_RUNTIME_DIR"
        # Use (id -u) instead of $UID which doesn't exist in Fish
        set -gx XDG_RUNTIME_DIR "/tmp/zellij-"(id -u)
        if test -d "$XDG_RUNTIME_DIR"
            # Fix permissions if needed (in case they were wrong)
            chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null
        else
            # Create directory with correct permissions
            mkdir -m 700 -p "$XDG_RUNTIME_DIR" 2>/dev/null
        end
    end

    # Auto-start zellij in new terminals (but not in existing zellij sessions)
    # Check if ZELLIJ env var exists and is not empty (it's set to "0" when in a session)
    # Also check that zellij command is available
    if status is-interactive && test -z "$ZELLIJ" && command -v zellij >/dev/null 2>&1
        zellij attach -c
    end
  '';
}