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

  # Create a robust wrapper script for Zellij that handles SSH edge cases
  home.file.".local/bin/zellij-safe" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Robust Zellij wrapper for SSH sessions

      # Function to create runtime directory with proper permissions
      create_runtime_dir() {
          local dir="$1"
          if [ ! -d "$dir" ]; then
              mkdir -p "$dir" 2>/dev/null || return 1
          fi
          chmod 700 "$dir" 2>/dev/null
          [ -w "$dir" ] && return 0 || return 1
      }

      # Ensure XDG_RUNTIME_DIR is set and usable
      if [ -z "$XDG_RUNTIME_DIR" ] || [ ! -w "$XDG_RUNTIME_DIR" ] 2>/dev/null; then
          uid=$(id -u)

          # Try standard locations in order of preference
          for candidate in "/run/user/$uid" "/tmp/runtime-$uid" "$HOME/.cache/runtime-$uid"; do
              if create_runtime_dir "$candidate"; then
                  export XDG_RUNTIME_DIR="$candidate"
                  break
              fi
          done

          # Last resort: use HOME directory
          if [ -z "$XDG_RUNTIME_DIR" ] || [ ! -w "$XDG_RUNTIME_DIR" ]; then
              export XDG_RUNTIME_DIR="$HOME/.cache/runtime-$uid"
              create_runtime_dir "$XDG_RUNTIME_DIR"
          fi
      fi

      # Ensure Zellij directories exist with proper permissions
      mkdir -p "$XDG_RUNTIME_DIR/zellij" 2>/dev/null
      chmod 755 "$XDG_RUNTIME_DIR/zellij" 2>/dev/null

      # Clean up stale sockets (important for SSH sessions)
      # Remove any socket files that are not currently in use
      if [ -d "$XDG_RUNTIME_DIR/zellij" ]; then
          # Get Zellij version directory
          for version_dir in "$XDG_RUNTIME_DIR/zellij"/*; do
              if [ -d "$version_dir" ]; then
                  # Check each socket file
                  for sock in "$version_dir"/*; do
                      if [ -S "$sock" ]; then
                          # Try to test if socket is alive using a simple method
                          # If we can't stat it or it's older than 1 day, remove it
                          if ! stat "$sock" >/dev/null 2>&1 || [ "$(find "$sock" -mtime +1 2>/dev/null)" ]; then
                              rm -f "$sock" 2>/dev/null
                          fi
                      fi
                  done
              fi
          done
      fi

      # Set socket directory explicitly
      export ZELLIJ_SOCKET_DIR="$XDG_RUNTIME_DIR/zellij"

      # Run zellij with the fixed environment
      exec ${pkgs.zellij}/bin/zellij "$@"
    '';
  };

  # Create an alias so 'zellij' uses our safe wrapper
  programs.fish.shellAliases = {
    zellij = "$HOME/.local/bin/zellij-safe";
  };

  # Also for bash
  programs.bash.shellAliases = {
    zellij = "$HOME/.local/bin/zellij-safe";
  };

  # Fish integration - add zellij autostart
  programs.fish.interactiveShellInit = ''
    # Set up runtime directory for Fish sessions
    function setup_runtime_dir
        set -l uid (id -u)

        # Check if XDG_RUNTIME_DIR is already properly set
        if test -n "$XDG_RUNTIME_DIR" -a -w "$XDG_RUNTIME_DIR" 2>/dev/null
            return 0
        end

        # Try standard locations
        for dir in "/run/user/$uid" "/tmp/runtime-$uid" "$HOME/.cache/runtime-$uid"
            if test -d "$dir" -o mkdir -m 700 -p "$dir" 2>/dev/null
                if test -w "$dir"
                    set -gx XDG_RUNTIME_DIR "$dir"
                    return 0
                end
            end
        end

        # Fallback
        set -gx XDG_RUNTIME_DIR "$HOME/.cache/runtime-$uid"
        mkdir -m 700 -p "$XDG_RUNTIME_DIR" 2>/dev/null
    end

    # Set up runtime directory immediately
    setup_runtime_dir

    # Add local bin to PATH for our wrapper
    if test -d "$HOME/.local/bin"
        fish_add_path -p "$HOME/.local/bin"
    end

    # Auto-start zellij in new terminals (but not in existing zellij sessions)
    if status is-interactive && test -z "$ZELLIJ"
        # Use our safe wrapper
        if test -f "$HOME/.local/bin/zellij-safe"
            "$HOME/.local/bin/zellij-safe" attach -c
        else if command -v zellij >/dev/null 2>&1
            # Fallback to regular zellij if wrapper not available yet
            zellij attach -c
        end
    end
  '';
}