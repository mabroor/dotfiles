{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./wezterm.nix
    ./zellij.nix
    ./neovim.nix
    ./ssh.nix
    ./fonts.nix
    ./theme.nix

    # Development environments
    ../modules/dev/javascript.nix
    ../modules/dev/python.nix
    ../modules/dev/go.nix
    ../modules/dev/rust.nix
  ];

  home = {
    stateVersion = "23.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      # Nix tooling
      marksman
      nixd

      # Modern CLI tools
      ripgrep # Better grep
      bat # Better cat with syntax highlighting
      eza # Better ls with colors and icons
      fd # Better find
      sd # Better sed
      delta # Better git diff
      btop # Better htop with more features
      dust # Disk usage analyzer
      procs # Better ps with colors
      lazygit # Terminal UI for git
      httpie # Better curl for APIs
      jless # JSON viewer for terminal

      # File and text processing
      jq # JSON processor
      yq # YAML/XML processor
      fzf # Fuzzy finder
      tree # Directory tree viewer
      tldr # Simplified man pages

      # Network and system tools
      bandwhich # Network bandwidth monitor
      bottom # System resource monitor
      zoxide # Better cd with smart jumping

      # Secret management is handled by the agenix module
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # hammerspoon = lib.mkIf pkgs.stdenvNoCC.isDarwin {
      #   source = ./../config/hammerspoon;
      #   target = ".hammerspoon";
      #   recursive = true;
      # };
    };

    sessionVariables = { };
  };


  programs = {
    # Use fish
    fish = {
      enable = true;

      # This runs for ALL fish instances - critical for SSH/su sessions
      shellInit = ''
        # CRITICAL: Load home-manager environment for SSH/su sessions
        # This MUST run before anything else tries to use Nix packages

        # Check if we're in a minimal environment (SSH/su) that needs PATH setup
        if not contains "$HOME/.nix-profile/bin" $PATH
            # Add home-manager managed packages to PATH
            set -gx PATH "$HOME/.nix-profile/bin" $PATH
        end

        # Source home-manager session variables. home-manager emits a native
        # fish version, so there is no need to shell out to bash and re-import
        # its `env` output — that copied read-only variables like `_` and
        # printed "set: Tried to change the read-only variable" on every
        # startup. It also split on a literal backslash-n rather than newline.
        if test -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.fish"
            source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.fish"
        end

        # Ensure all Nix paths are available
        for p in /run/current-system/sw/bin /nix/var/nix/profiles/default/bin /etc/profiles/per-user/(whoami)/bin
            if test -d $p; and not contains $p $PATH
                set -gx PATH $PATH $p
            end
        end
      '';

      interactiveShellInit = ''
        set fish_greeting # N/A

        # Configure Tide prompt
        if not set -q tide_configured
          tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Many icons' --transient=No
          set -U tide_configured 1
        end
      '';

      shellAliases = {
        # Modern CLI tool aliases
        ls = "eza --icons";
        ll = "eza -l --icons --git";
        la = "eza -la --icons --git";
        tree = "eza --tree --icons";
        cat = "bat --paging=never";
        find = "fd";
        grep = "rg";

        # Git aliases
        g = "git";
        lg = "lazygit";

        # Other useful aliases
        top = "btop";
        du = "dust";
        ps = "procs";
        cd = "z"; # Use zoxide for smart jumping
      };

      plugins = [
        {
          name = "nix-env";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
            hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
          };
        }
        {
          name = "tide";
          src = pkgs.fetchFromGitHub {
            owner = "IlanCosman";
            repo = "tide";
            rev = "v6.1.1";
            hash = "sha256-ZyEk/WoxdX5Fr2kXRERQS1U1QHH3oVSyBQvlwYnEYyc=";
          };
        }
      ];
    };

    # Configure bat (better cat)
    bat = {
      enable = true;
      config = {
        theme = lib.mkDefault "TwoDark";
        pager = "less -FR";
      };
    };

    # Configure eza (better ls)  
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = false;
    };

    # Configure fzf
    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type f";
      defaultOptions = [
        "--height 50%"
        "--border"
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
    };

    # Configure zoxide (better cd)
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };


  };
}
