# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based dotfiles repository for managing development environment configurations across macOS (Intel and Apple Silicon) and NixOS systems. It uses Nix Flakes, nix-darwin, and home-manager for declarative system management.

## Key Commands

### Bootstrap and Update Commands

**Darwin/macOS:**
```bash
# Initial bootstrap (from remote)
nix run nix-darwin -- switch --flake github:mabroor/dotfiles

# Update local configuration
darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
```

**NixOS:**
```bash
# Update system configuration
sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
```

### Development Commands

```bash
# Update flake inputs
nix flake update

# Check flake configuration
nix flake check

# Show flake outputs
nix flake show
```

## Architecture and Structure

### Core Components

**flake.nix** (root): Main entry point defining:
- NixOS configurations for Linux systems
- Darwin configurations for macOS systems (both Intel and Apple Silicon)
- System-specific module imports and home-manager integration

**darwin/darwin.nix**: macOS-specific system configuration including:
- Homebrew package management (casks and Mac App Store apps)
- System defaults (Dock, Finder settings)
- Nix daemon configuration with flakes enabled
- Font management (Monaspace, Atkinson Hyperlegible)

**home/**: User-level configurations managed by home-manager:
- **home.nix**: Main home configuration importing other modules
- **git.nix**: Git configuration with custom aliases and settings
- **wezterm.nix**: WezTerm terminal configuration

**config/**: Dotfile sources linked by home-manager:
- **git/.gitconfig**: Extensive git aliases and configuration
- **wezterm/.wezterm.lua**: WezTerm terminal settings

### System Configurations

The repository supports multiple machine configurations:
- **AMAFCXNW09RYR**: Apple Silicon Mac (aarch64-darwin) with user "mabroor.ahmed"
- **Mabroors-MacBook-Pro**: Intel Mac (x86_64-darwin) with user "mabroor"
- **nixos**: Generic NixOS system (x86_64-linux)

### Key Design Patterns

1. **Modular Configuration**: Separate modules for different tools (git, wezterm) imported into main home.nix
2. **Cross-Platform Support**: Conditional configurations for Darwin vs NixOS systems
3. **Declarative Package Management**: All system and user packages defined in Nix expressions
4. **Home-Manager Integration**: User-specific configurations managed separately from system-level settings

## Important Configuration Details

- Fish shell is the default with nix-env plugin for proper Nix environment handling
- Direnv with nix-direnv enabled for per-project environments
- Git is configured to use SSH for GitHub operations (converts HTTPS URLs automatically)
- Homebrew integration on macOS manages GUI applications not available in nixpkgs