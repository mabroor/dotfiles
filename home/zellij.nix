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
  
  # Fish integration - add zellij autostart
  programs.fish.interactiveShellInit = ''
    # Auto-start zellij in new terminals (but not in existing zellij sessions)
    if status is-interactive && not set -q ZELLIJ
        zellij attach -c
    end
  '';
}