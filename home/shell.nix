# Shell configuration module for Fish and Bash
# This module configures both Fish and Bash shells with common development tools
# and environment setups based on system usage patterns

{ config, pkgs, lib, ... }:

let
  # Determine if we're on macOS or Linux
  isDarwin = pkgs.stdenvNoCC.isDarwin;
  isLinux = pkgs.stdenvNoCC.isLinux;
  
  # Homebrew prefix paths for different systems
  homebrewPrefix = if isDarwin then "/opt/homebrew" else "/home/linuxbrew/.linuxbrew";
in
{
  programs = {
    # Fish shell configuration
    fish = {
      enable = true;
      
      # Interactive shell initialization
      interactiveShellInit = ''
        # Disable greeting message
        set fish_greeting
        
        # Homebrew environment setup
        # Detects and configures Homebrew for both macOS and Linux
        if test -d /home/linuxbrew/.linuxbrew
          # Linux Homebrew configuration
          set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
          set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
          set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
        else if test -d /opt/homebrew
          # macOS Apple Silicon Homebrew configuration
          set -gx HOMEBREW_PREFIX "/opt/homebrew"
          set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
          set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX"
        else if test -d /usr/local/Homebrew
          # macOS Intel Homebrew configuration
          set -gx HOMEBREW_PREFIX "/usr/local"
          set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
          set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
        end
        
        # Add Homebrew to PATH if it exists
        if set -q HOMEBREW_PREFIX
          fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
          
          # Configure MANPATH for Homebrew
          if not set -q MANPATH
            set -gx MANPATH ''
          end
          set -gx MANPATH "$HOMEBREW_PREFIX/share/man" $MANPATH
          
          # Configure INFOPATH for Homebrew
          if not set -q INFOPATH
            set -gx INFOPATH ''
          end
          set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH
        end
        
        # Node Version Manager (nvm) setup for Fish
        # Note: nvm doesn't have official Fish support, but we can set up the paths
        if test -d $HOME/.nvm
          set -gx NVM_DIR "$HOME/.nvm"
          # Add default node version to PATH if it exists
          if test -d "$NVM_DIR/versions/node"
            set -l default_node (ls -1 "$NVM_DIR/versions/node" | tail -1)
            if test -n "$default_node"
              fish_add_path -gP "$NVM_DIR/versions/node/$default_node/bin"
            end
          end
        end
        
        # Rust/Cargo environment setup
        # Rustup installs to ~/.cargo/bin by default
        if test -d $HOME/.cargo
          set -gx CARGO_HOME "$HOME/.cargo"
          set -gx RUSTUP_HOME "$HOME/.rustup"
          fish_add_path -gP "$CARGO_HOME/bin"
          
          # Set Rust-specific environment variables
          set -gx RUST_BACKTRACE 1  # Enable backtraces for better debugging
        end
      '';
      
      # Shell aliases for common operations
      shellAliases = {
        # Nix-related aliases
        rebuild = if isDarwin 
          then "darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles"
          else "sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles";
        
        # Common development aliases
        ll = "ls -la";
        la = "ls -A";
        l = "ls -CF";
        
        # Git aliases (basic ones, complex ones are in git.nix)
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git log --oneline --graph";
        
        # Rust/Cargo aliases
        cb = "cargo build";
        cr = "cargo run";
        ct = "cargo test";
        cc = "cargo check";
        cf = "cargo fmt";
        clippy = "cargo clippy";
      };
      
      # Fish plugins
      plugins = [
        # Nix environment integration
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
      
      # Fish functions for development workflows
      functions = {
        # Function to quickly setup a new Node.js project
        node-init = ''
          function node-init
            if test (count $argv) -eq 0
              echo "Usage: node-init <project-name>"
              return 1
            end
            
            mkdir -p $argv[1]
            cd $argv[1]
            npm init -y
            echo "Node.js project initialized in $argv[1]"
          end
        '';
        
        # Function to update all Homebrew packages
        brew-update-all = lib.mkIf (isDarwin || isLinux) ''
          function brew-update-all
            if command -v brew > /dev/null
              echo "Updating Homebrew..."
              brew update
              echo "Upgrading packages..."
              brew upgrade
              echo "Cleaning up..."
              brew cleanup
            else
              echo "Homebrew not found"
            end
          end
        '';
        
        # Function to quickly setup a new Rust project
        rust-init = ''
          function rust-init
            if test (count $argv) -eq 0
              echo "Usage: rust-init <project-name> [--lib]"
              return 1
            end
            
            set project_name $argv[1]
            
            if test "$argv[2]" = "--lib"
              cargo new --lib $project_name
            else
              cargo new $project_name
            end
            
            cd $project_name
            echo "Rust project initialized in $project_name"
          end
        '';
        
        # Function to update Rust toolchain
        rust-update = ''
          function rust-update
            if command -v rustup > /dev/null
              echo "Updating Rust toolchain..."
              rustup update
              echo "Rust toolchain updated successfully"
            else
              echo "rustup not found. Install it from https://rustup.rs"
            end
          end
        '';
      };
    };
    
    # Bash shell configuration (as fallback and for compatibility)
    bash = {
      enable = true;
      
      # Bash initialization for interactive shells
      initExtra = ''
        # Homebrew environment setup for Bash
        if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
          # Linux Homebrew
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [[ -d "/opt/homebrew" ]]; then
          # macOS Apple Silicon Homebrew
          eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -d "/usr/local/Homebrew" ]]; then
          # macOS Intel Homebrew
          eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Node Version Manager (nvm) setup
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        
        # Rust/Cargo environment setup
        if [ -d "$HOME/.cargo" ]; then
          export CARGO_HOME="$HOME/.cargo"
          export RUSTUP_HOME="$HOME/.rustup"
          export PATH="$CARGO_HOME/bin:$PATH"
          
          # Set Rust-specific environment variables
          export RUST_BACKTRACE=1  # Enable backtraces for better debugging
          
          # Source cargo env if it exists (for rustup completions)
          [ -s "$CARGO_HOME/env" ] && \. "$CARGO_HOME/env"
        fi
        
        # Set default editor
        export EDITOR="${if config.programs.neovim.enable then "nvim" else "vim"}"
        
        # Improve command history
        export HISTSIZE=10000
        export HISTFILESIZE=20000
        export HISTCONTROL=ignoreboth:erasedups
        
        # Enable bash completion for various tools
        if [ -f /etc/bash_completion ]; then
          . /etc/bash_completion
        fi
      '';
      
      # Bash aliases (similar to Fish aliases)
      shellAliases = {
        # Nix-related aliases
        rebuild = if isDarwin 
          then "darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles"
          else "sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles";
        
        # Common development aliases
        ll = "ls -la";
        la = "ls -A";
        l = "ls -CF";
        
        # Git aliases
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git log --oneline --graph";
        
        # Rust/Cargo aliases
        cb = "cargo build";
        cr = "cargo run";
        ct = "cargo test";
        cc = "cargo check";
        cf = "cargo fmt";
        clippy = "cargo clippy";
      };
    };
    
    # Additional shell-agnostic programs
    
    # Direnv for per-project environment management
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      
      # Enable direnv for both Fish and Bash
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    
    # Starship prompt (commented out as in original, but configured)
    # Uncomment to enable a modern, fast prompt for both shells
    # starship = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableFishIntegration = true;
    #   
    #   settings = {
    #     command_timeout = 100;
    #     format = "[$all](dimmed white)";
    #     
    #     character = {
    #       success_symbol = "[❯](dimmed green)";
    #       error_symbol = "[❯](dimmed red)";
    #     };
    #     
    #     git_status = {
    #       style = "bold yellow";
    #       format = "([$all_status$ahead_behind]($style) )";
    #     };
    #     
    #     jobs.disabled = true;
    #   };
    # };
  };
  
  # Home packages for shell development
  home.packages = with pkgs; [
    # Shell utilities
    shellcheck        # Shell script linter
    shfmt            # Shell script formatter
    
    # Development tools commonly used
    curl             # HTTP client
    wget             # Alternative HTTP client
    jq               # JSON processor
    yq               # YAML processor
    htop             # Process viewer
    tree             # Directory tree viewer
    ncdu             # Disk usage analyzer
    
    # Build tools (as seen in history)
    gnumake          # Make build tool
    gcc              # C/C++ compiler
    
    # Rust development tools
    # Note: rustup itself manages the Rust toolchain, but we include useful tools
    rustup           # Rust toolchain installer and version manager
    pkg-config       # Helper tool for compiling applications (needed by many Rust crates)
    openssl          # SSL/TLS toolkit (commonly needed for Rust projects)
    
    # Version control
    gh               # GitHub CLI (as seen in history)
  ] ++ lib.optionals isLinux [
    # Linux-specific tools
    file             # File type identifier
    procps           # Process utilities
  ];
  
  # Environment variables
  home.sessionVariables = {
    # Set default editor based on what's available
    EDITOR = if config.programs.neovim.enable then "nvim"
             else if config.programs.vim.enable then "vim"
             else "nano";
    
    # Pager configuration
    PAGER = "less";
    LESS = "-R";
    
    # Development environment variables
    NODE_ENV = "development";  # Default Node environment
    
    # Rust environment variables
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
    RUST_BACKTRACE = "1";  # Enable backtraces for better debugging
  };
  
  # Shell-related dotfiles
  home.file = {
    # Create .hushlogin to suppress login messages on macOS
    ".hushlogin" = lib.mkIf isDarwin {
      text = "";
    };
    
    # Global gitignore for development
    ".gitignore_global" = {
      text = ''
        # OS generated files
        .DS_Store
        .DS_Store?
        ._*
        .Spotlight-V100
        .Trashes
        ehthumbs.db
        Thumbs.db
        
        # Editor directories and files
        .idea/
        .vscode/
        *.swp
        *.swo
        *~
        
        # Dependencies
        node_modules/
        vendor/
        
        # Environment files
        .env
        .env.local
        .env.*.local
        
        # Build outputs
        dist/
        build/
        out/
        
        # Logs
        *.log
        npm-debug.log*
        yarn-debug.log*
        yarn-error.log*
      '';
    };
  };
}