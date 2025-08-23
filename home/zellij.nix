# Zellij terminal multiplexer configuration
{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    
    settings = {
      # Theme configuration
      theme = "catppuccin-macchiato";
      
      # Default shell
      default_shell = "fish";
      
      # Copy on select
      copy_on_select = false;
      
      # Scroll buffer size
      scroll_buffer_size = 10000;
      
      # Mouse mode
      mouse_mode = true;
      
      # Pane frames
      pane_frames = true;
      
      # Auto layout
      auto_layout = true;
      
      # Session serialization
      session_serialization = false;
      
      # Simplified UI
      simplified_ui = false;
      
      # Default layout
      default_layout = "compact";
      
      # Default mode
      default_mode = "normal";
      
      # UI configuration
      ui = {
        pane_frames = {
          rounded_corners = true;
          hide_session_name = false;
        };
      };
      
      # Keybindings
      keybinds = {
        normal = {
          # Unbind some default keys to avoid conflicts
          "Ctrl q" = [];
          
          # Custom keybindings
          "Alt h" = { MoveFocus = "Left"; };
          "Alt l" = { MoveFocus = "Right"; };
          "Alt j" = { MoveFocus = "Down"; };
          "Alt k" = { MoveFocus = "Up"; };
          
          # Pane management
          "Alt |" = { NewPane = "Right"; };
          "Alt _" = { NewPane = "Down"; };
          "Alt x" = { CloseFocus = null; };
          
          # Tab management
          "Alt t" = { NewTab = null; };
          "Alt w" = { CloseTab = null; };
          "Alt 1" = { GoToTab = 1; };
          "Alt 2" = { GoToTab = 2; };
          "Alt 3" = { GoToTab = 3; };
          "Alt 4" = { GoToTab = 4; };
          "Alt 5" = { GoToTab = 5; };
          
          # Session management
          "Alt d" = { Detach = null; };
          "Alt f" = { ToggleFloatingPanes = null; };
          "Alt m" = { ToggleFocusFullscreen = null; };
          
          # Search
          "Ctrl s" = { SwitchToMode = "Search"; };
        };
        
        search = {
          "Enter" = { SwitchToMode = "Normal"; };
          "Esc" = { SwitchToMode = "Normal"; };
          "Ctrl c" = { SwitchToMode = "Normal"; };
        };
        
        resize = {
          "h" = { Resize = "Left"; };
          "j" = { Resize = "Down"; };
          "k" = { Resize = "Up"; };
          "l" = { Resize = "Right"; };
          "=" = { Resize = "Increase"; };
          "-" = { Resize = "Decrease"; };
          "Enter" = { SwitchToMode = "Normal"; };
          "Esc" = { SwitchToMode = "Normal"; };
        };
      };
      
      # Plugins
      plugins = {
        tab-bar = { path = "tab-bar"; };
        status-bar = { path = "status-bar"; };
        strider = { path = "strider"; };
        compact-bar = { path = "compact-bar"; };
      };
      
      # Layout templates
      layouts = {
        default = {
          tabs = [
            {
              name = "main";
              parts = [
                { direction = "Vertical"; parts = [
                  { direction = "Horizontal"; parts = [
                    { direction = "Vertical"; borderless = true; }
                    { direction = "Vertical"; split_size = { Percent = 30; }; }
                  ]; }
                  { direction = "Horizontal"; split_size = { Percent = 20; }; }
                ]; }
              ];
            }
          ];
        };
      };
    };
  };
  
  # Fish integration - add zellij autostart
  programs.fish.interactiveShellInit = ''
    # Auto-start zellij in new terminals (but not in existing zellij sessions)
    if status is-interactive && not set -q ZELLIJ
        zellij attach -c
    end
  '';
}