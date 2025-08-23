
{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./wezterm.nix
    ./zellij.nix
    ./neovim.nix
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

    starship = {
      enable = true;

      settings = {
        # Global settings
        command_timeout = 1000;
        add_newline = true;
        
        # Custom format with more segments
        format = ''
          $username$hostname$directory$git_branch$git_commit$git_state$git_status$package$nodejs$rust$golang$python$nix_shell$memory_usage$aws$gcloud$kubernetes$docker_context$terraform$vagrant$cmd_duration$line_break$jobs$battery$time$status$character
        '';

        # Character configuration
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vicmd_symbol = "[❮](bold yellow)";
        };

        # Username (show when SSH or root)
        username = {
          show_always = false;
          style_user = "bold blue";
          style_root = "bold red";
          format = "[$user]($style)";
        };

        # Hostname (show when SSH)
        hostname = {
          ssh_only = true;
          format = "@[$hostname](bold blue) ";
          disabled = false;
        };

        # Directory
        directory = {
          style = "bold cyan";
          truncation_length = 3;
          truncation_symbol = "…/";
          home_symbol = "~";
          read_only = " ";
          read_only_style = "197";
          format = "at [$path]($style)[$read_only]($read_only_style) ";
        };

        # Git branch
        git_branch = {
          symbol = " ";
          style = "bold purple";
          format = "on [$symbol$branch]($style) ";
        };

        # Git status
        git_status = {
          style = "red";
          ahead = "⇡\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          behind = "⇣\${count}";
          conflicted = "=\${count}";
          deleted = "✘\${count}";
          renamed = "»\${count}";
          modified = "!\${count}";
          staged = "+\${count}";
          untracked = "?\${count}";
          format = "([$all_status$ahead_behind]($style) )";
        };

        # Programming languages
        nodejs = {
          symbol = " ";
          style = "bold green";
          format = "via [$symbol($version )]($style)";
        };

        rust = {
          symbol = " ";
          style = "bold red";
          format = "via [$symbol($version )]($style)";
        };

        golang = {
          symbol = " ";
          style = "bold cyan";
          format = "via [$symbol($version )]($style)";
        };

        python = {
          symbol = " ";
          style = "bold yellow";
          format = "via [$symbol$pyenv_prefix($version )(\($virtualenv\) )]($style)";
        };

        # Package version
        package = {
          symbol = "📦 ";
          style = "208";
          format = "[$symbol$version]($style) ";
          disabled = false;
        };

        # Nix shell
        nix_shell = {
          symbol = " ";
          style = "bold blue";
          format = "via [$symbol$state( \($name\))]($style) ";
        };

        # Memory usage
        memory_usage = {
          disabled = false;
          threshold = 75;
          symbol = " ";
          style = "bold dimmed red";
          format = "via $symbol[\${ram}( | \${swap})]($style) ";
        };

        # Cloud providers
        aws = {
          symbol = "☁️ ";
          style = "bold yellow";
          format = "on [$symbol($profile )(\($region\) )]($style)";
        };

        gcloud = {
          symbol = "☁️ ";
          style = "bold blue";
          format = "on [$symbol$account(@$domain)(\($region\))]($style) ";
        };

        # Container and orchestration
        docker_context = {
          symbol = " ";
          style = "blue bold";
          format = "via [$symbol$context]($style) ";
        };

        kubernetes = {
          symbol = "☸ ";
          style = "cyan bold";
          format = "on [$symbol$context( \($namespace\))]($style) ";
          disabled = false;
        };

        # Infrastructure as Code
        terraform = {
          symbol = "💠 ";
          style = "bold purple";
          format = "via [$symbol$workspace]($style) ";
        };

        # Command duration
        cmd_duration = {
          min_time = 2000;
          style = "yellow bold";
          format = "took [$duration]($style) ";
        };

        # Jobs
        jobs = {
          threshold = 1;
          symbol = "+ ";
          style = "bold blue";
          format = "[$symbol$number]($style) ";
        };

        # Battery
        battery = {
          full_symbol = " ";
          charging_symbol = " ";
          discharging_symbol = " ";
          unknown_symbol = " ";
          empty_symbol = " ";

          display = [
            {
              threshold = 10;
              style = "bold red";
            }
            {
              threshold = 30;
              style = "bold yellow";
            }
          ];
        };

        # Time
        time = {
          disabled = false;
          style = "bold white";
          format = "🕐[$time]($style) ";
          time_format = "%T";
        };

        # Status (exit code)
        status = {
          style = "red bold";
          symbol = "✖";
          format = "[$symbol $common_meaning$signal_name$maybe_int]($style) ";
          map_symbol = true;
          disabled = false;
        };
      };
    };

  };
}
