
{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./wezterm.nix
    ./zellij.nix
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
      ripgrep    # Better grep
      bat        # Better cat with syntax highlighting
      eza        # Better ls with colors and icons
      fd         # Better find
      sd         # Better sed
      delta      # Better git diff
      btop       # Better htop with more features
      dust       # Disk usage analyzer
      procs      # Better ps with colors
      lazygit    # Terminal UI for git
      httpie     # Better curl for APIs
      jless      # JSON viewer for terminal

      # File and text processing
      jq         # JSON processor
      yq         # YAML/XML processor
      fzf        # Fuzzy finder
      tree       # Directory tree viewer
      tldr       # Simplified man pages

      # Network and system tools
      bandwhich  # Network bandwidth monitor
      bottom     # System resource monitor
      zoxide     # Better cd with smart jumping
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

    sessionVariables = {
    };
  };

  programs = {
    # Use fish
    fish = {
      enable = true;

      interactiveShellInit = ''
        set fish_greeting # N/A
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
      ];
    };

    # Configure bat (better cat)
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        pager = "less -FR";
      };
    };

    # Configure eza (better ls)  
    eza = {
      enable = true;
      enableAliases = false; # We set our own aliases above
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

    # starship = {
    #   enable = true;

    #   settings = {
    #     command_timeout = 100;
    #     format = "[$all](dimmed white)";

    #     character = {
    #       success_symbol = "[❯](dimmed green)";
    #       error_symbol = "[❯](dimmed red)";
    #     };

    #     git_status = {
    #       style = "bold yellow";
    #       format = "([$all_status$ahead_behind]($style) )";
    #     };

    #     jobs.disabled = true;
    #   };
    # };

  };
}
